# frozen_string_literal: true

# トレンドへの追随度 (TL上のツイートの特徴語と特定のユーザーのツイートの特徴語の類似度) を算出する

require_relative 'config/environment'
require_relative 'service/key_phrase_service'

key_phrase_services = { timeline: true, user: false }.map do |kind, is_all|
  [kind, KeyPhraseService.new(is_all)]
end.to_h

about_options = { program_name: Plugin::MatchTrend::Environment::NAME,
                  version: Plugin::MatchTrend::Environment::VERSION,
                  comments: Plugin::MatchTrend::Environment::DESCRIPTION,
                  license: begin
                             path = File.expand_path('LICENSE', __dir__)
                             file_get_contents(path)
                           rescue StandardError
                             nil
                           end,
                  website: 'https://github.com/massongit/mikutter_match_trend',
                  authors: [Plugin::MatchTrend::Environment::AUTHOR] }

Plugin.create(:match_trend) do
  defactivity(:match_trend, 'トレンドへの追随度')

  settings('トレンドへの追随度') do
    title = 'Yahoo! JAPAN Webサービス用アプリケーションID'
    inputpass(title, :match_trend_yahoo_app_id).tooltip(title)
    title = '対象アカウント'
    input(title, :match_trend_twitter_screen_name).tooltip(title)
    title = '取得間隔 (秒)'
    adjustment(title, :match_trend_interval, 2, 604_800).tooltip(title)
    about("#{Plugin::MatchTrend::Environment::NAME}について", about_options)
  end

  on_userconfig_modify do |key, new_val|
    key_phrase_services[:user].screen_name = new_val if key == :match_trend_twitter_screen_name
  end

  on_update do |_service, messages|
    messages.each do |message|
      key_phrase_services.values.each do |key_phrase_service|
        key_phrase_service << message
      end
    end

    key_phrases = []
    is_empty = false

    key_phrase_services.values.each do |key_phrase_service|
      break if is_empty

      key_phrase = key_phrase_service.generate_list_by_percentage
      key_phrases.append(key_phrase)
      is_empty ||= key_phrase.empty?
    end

    unless is_empty
      percent = 100.0 * key_phrases.inject(&:&).size / key_phrases.min.size
      output = ["@#{key_phrase_services[:user].screen_name}さんのトレンドへの追随度",
                format('%<percent>.2f%%', percent: percent)]
      activity(:match_trend, output.join("\n"), icon: Skin['icon.png'])
    end
  end
end
