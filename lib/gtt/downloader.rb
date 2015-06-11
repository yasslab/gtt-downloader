require "gtt/downloader/version"
require "capybara"

module Gtt
  URL = 'http://translate.google.com/toolkit/'

  class Downloader
    def initialize(email = ENV['GMAIL_ADDR'], password = ENV['GMAIL_PASS'])
      unless email && password
        raise 'email or password is not set'
      end

      @email    = email
      @password = password
    end

    def download_label(label)
      session = nil

      Capybara.using_wait_time(wait_time) do
        session = signed_in_session

        session.click_on(label)
        # FIXME ラベルが選択されアイテムが表示されるのを待つ
        sleep 10

        # リストにフォーカスを当てておく
        session.find('.gtc-list-body tr:first-child .gtc-listview-col-checkbox .jfk-checkbox').click
        session.find('.gtc-list-body tr:first-child .gtc-listview-col-checkbox .jfk-checkbox').click

        # 全部表示する
        while session.first('#item-count', text: 'of many')
          session.find('body').native.send_key(:arrow_down)
        end

        session.find('#select-menu-button').click
        # FIXME ファイルが選択されるのを待つ
        sleep 10

        archive_path_helper do
          session.find('#download-button').click
          # FIXME ダウンロードを待つ
          begin
            sleep 1
          end while session.windows.length != 1
        end
      end
    ensure
      if session
        session.cleanup!
        session.driver.quit
      end
    end

    private

    def archive_path_helper(&action)
      previous_archive_paths = archive_paths

      action.call

      downloaded_archive_paths = archive_paths - previous_archive_paths

      if downloaded_archive_paths.count.zero?
        raise "Download failed"
      end

      if downloaded_archive_paths.count != 1
        raise "Ambiguous archive_path: #{downloaded_archive_paths.inspect}"
      end

      downloaded_archive_paths[0]
    end

    def archive_paths
      Dir.glob(File.expand_path('~/Downloads/archive*.zip'))
    end

    def gtt_driver
      unless Capybara.drivers.has_key?(:gtt_downloader)
        Capybara.register_driver :gtt_downloader do |app|
          Capybara::Selenium::Driver.new(app, browser: :chrome)
        end
      end

      :gtt_downloader
    end

    def signed_in_session
      session = Capybara::Session.new(gtt_driver)
      session.visit(::Gtt::URL)
      session.fill_in 'Email',  with: @email
      session.fill_in 'Passwd', with: @password
      session.click_on 'signIn'
      session
    end

    def wait_time
      600
    end
  end
end
