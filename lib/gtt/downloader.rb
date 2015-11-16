# -*- coding: utf-8 -*-
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

        if session.first('#item-count', text: '1-1 of 1')
          filename = session.first('.gtc-list-row-select .gtc-listview-doc-col-name > div:first-child').text
        else
          filename = nil
        end

        archive_path_helper(filename: filename) do
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

    def archive_path_helper(filename: nil, &action)
      previous_archive_paths = archive_paths(filename)

      action.call

      downloaded_archive_paths = archive_paths(filename) - previous_archive_paths

      if downloaded_archive_paths.count.zero?
        raise "Download failed"
      end

      if downloaded_archive_paths.count != 1
        raise "Ambiguous archive_path: #{downloaded_archive_paths.inspect}"
      end

      downloaded_archive_paths[0]
    end

    def archive_paths(filename = nil)
      if filename
        Dir.glob(File.join(File.expand_path("~/Downloads/"), "#{filename}*"))
      else
        Dir.glob(File.expand_path('~/Downloads/archive*.zip'))
      end
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

      Capybara.using_wait_time(2) do
        session.visit(::Gtt::URL)
        session.fill_in  'Email',  with: @email
        session.click_on 'Next' if session.has_button? 'Next'
        session.click_on '次へ' if session.has_button? '次へ'
        session.fill_in  'Passwd', with: @password
        session.click_on 'signIn'
        session
      end
    end

    def wait_time
      600
    end
  end
end
