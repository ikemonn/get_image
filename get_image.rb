require "open-uri"
require "FileUtils"
require "cgi"
require "json"

def save_image(url)
  # basenameは一番最後のスラッシュに続く要素を返す
  fileName = File.basename(url)
  dirName  = "./get_images/"
  filePath = dirName + fileName
  # フォルダがなければ作成する
  FileUtils.mkdir_p(dirName) unless FileTest.exist?(dirName)
  # 画像を保存する 
  open(filePath, 'wb') do |output|
    open(url) do |data|
      output.write(data.read)
    end
  end
end

# 検索ワードをエンコーディングする
search_word = CGI::escape(ARGV[0])
start = 0

# APIの仕様で1度に8ページ×8URLしか画像を表示できないらしい
while start <= 64 
  url = "http://ajax.googleapis.com/ajax/services/search/images?q=#{search_word}&v=1.0&hl=ja&rsz=large&start=#{start}&safe=off"
  page = open(url)
  page.each_line do |line|
    begin
      # 200番以外が返ってきたら次へ
      next if JSON[line]['responseStatus'] != 200
      # レスポンスデータから画像のURLを取得してフォルダに保存
      search_results = JSON[line]['responseData']
      search_results['results'].each do |search_result|
        save_image(search_result['url']) if search_result['url'] =~ /(\.png\z|\.jpg\z$|\.gif\z|\.jpeg\z)/i
        p "#{search_result['url']}をDLしました"
      end
    rescue
      next
    end
  end
  start += 8
end
