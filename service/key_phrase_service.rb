# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

# 文章中から特徴語を抽出する
class KeyPhraseService
  attr_reader :screen_name

  def initialize(is_all = true)
    uri = URI.parse('https://jlp.yahooapis.jp/KeyphraseService/V1/extract')
    @http = Net::HTTP.new(uri.host, uri.port)
    @http.use_ssl = true
    @request = Net::HTTP::Post.new(uri.request_uri)
    @sentences = []
    @screen_name = is_all ? ALL : UserConfig[:match_trend_twitter_screen_name]
    set_next_time
  end

  def <<(other)
    return if @screen_name != ALL && @screen_name != other[:user].to_s
    return unless other[:message].is_a?(String)

    replace_patterns = [/^RT +/, /[\w:@+-_.]+/, URI::DEFAULT_PARSER.make_regexp]

    message = replace_patterns.inject(other[:message]) do |m, p|
      m.gsub(p, '')
    end

    @sentences.append(message.strip)
  end

  def screen_name=(screen_name)
    @screen_name = screen_name
    @sentences.clear
  end

  # 文章中から特徴語を抽出する
  # @return 特徴語一覧
  def get
    set_request
    key_phrases = {}

    if extract_request_or_set_time?
      unless @next_time.nil?
        key_phrases = JSON.parse(@http.request(@request).body)
        @sentences.clear
      end

      set_next_time
    end

    key_phrases
  end

  # 文章中から特徴語を抽出後、特徴語のスコアを割合と捉えて、それと同じ割合の特徴語を含むリストを作成する
  # @return 特徴語のリスト
  def generate_list_by_percentage
    key_phrases = get
    sum_score = key_phrases.values.inject(&:+)
    key_phrases_by_percentage = []

    key_phrases.each do |key_phrase, score|
      (100.0 * score / sum_score + 0.5).to_i.times do |_|
        key_phrases_by_percentage.append(key_phrase)
      end
    end

    key_phrases_by_percentage
  end

  private

  ALL = 'ALL'

  # 特徴語の抽出や特徴語の次回取得時刻の設定を行うかどうか
  # @return 特徴語の抽出や特徴語の次回取得時刻の設定を行うかどうか
  def extract_request_or_set_time?
    !@request.body.empty? && (@next_time.nil? || @next_time <= Time.now)
  end

  # requestをセットする
  def set_request
    app_id = UserConfig[:match_trend_yahoo_app_id]

    if app_id.nil? || app_id.empty?
      @request.form_data = {}
    else
      normalize_sentences(app_id)
    end
  end

  # リクエストのデータサイズが上限を超えないよう、sentenceの長さを調整する
  # @param app_id Yahoo! JAPAN Webサービス用アプリケーションID
  def normalize_sentences(app_id)
    until @sentences.empty?
      @request.form_data = { appid: app_id,
                             output: 'json',
                             sentence: @sentences.join }
      return if @request.body.length < 102_400

      @sentences.shift
    end
  end

  # 特徴語の次回取得時刻を設定する
  def set_next_time
    interval = UserConfig[:match_trend_interval]
    @next_time = interval.nil? ? nil : Time.now + interval
  end
end
