# -*- coding: utf-8 -*-
require 'acceptance_helper'

feature 'spamフィルタ設定の利用' do
	scenario '新入荷のプラグインが表示される' do
		visit '/update.rb?conf=sf'

		click_button 'OK'
		page.should_not have_content '新入荷'

		FileUtils.cp_r "#{TDiary::PATH}/spec/fixtures/sample.rb", "#{TDiary::PATH}/misc/filter/"

		click_link 'スパムフィルター選択'
		page.should have_content '新入荷'
		page.should have_content 'sample.rb'

		FileUtils.rm "#{TDiary::PATH}/misc/filter/sample.rb"
	end

	scenario 'スパムフィルター選択が保存される' do
		FileUtils.cp_r "#{TDiary::PATH}/spec/fixtures/sample.rb", "#{TDiary::PATH}/misc/filter/"

		visit '/update.rb?conf=sf'
		check "sf.sample.rb"
		click_button 'OK'

		page.should have_checked_field "sf.sample.rb"

		FileUtils.rm "#{TDiary::PATH}/misc/filter/sample.rb"
	end

	scenario 'プラグインが消えたら表示されない' do
		FileUtils.cp_r "#{TDiary::PATH}/spec/fixtures/sample.rb", "#{TDiary::PATH}/misc/filter/"

		visit '/update.rb?conf=sf'
		page.should have_content 'sample.rb'

		FileUtils.rm "#{TDiary::PATH}/misc/filter/sample.rb"
		click_link 'スパムフィルター選択'
		page.should_not have_content 'sample.rb'
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
