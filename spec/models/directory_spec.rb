require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Directory do
  fixtures :directories, :pasokara_files

  before(:each) do
    @valid_attributes = {
      :name => "C&C",
      :fullpath => "E:\\pasokara\\石鹸屋",
      :rootpath => "E:\\pasokara",
    }

    @cool_and_create = directories(:cool_and_create)
  end

  it "適切なパラメーターで作成されること" do
    Directory.create!(@valid_attributes)
  end

  it "entitiesメソッドで、下位ディレクトリ、ファイルのリストを返すこと" do
    @cool_and_create.should have(2).entities
  end

  it "Directory.structメソッドで、指定したディレクトリ以下を再帰的に取得し、データベースを構築すること" do
    top_dir_count = Directory.find(:all, :conditions => ["directory_id is null"]).length
    Directory.struct("/var/www/virtualhtml/pasokara/shared/pasokara")
    Directory.find(:all).length.should >= 50
    Directory.find(:all, :conditions => ["directory_id is null"]).length.should > top_dir_count
    Directory.find(:first, :conditions => ["fullpath = ?", "/var/www/virtualhtml/pasokara/shared/pasokara/0000"]).should have_at_least(20).entities
    Directory.find(:all, :conditions => ["rootpath = ?", "/var/www/virtualhtml/pasokara/shared/pasokara"]).length.should >= 50
  end

  it "フルパスが同一のディレクトリは作成できない" do
    Directory.create(@valid_attributes)
    Directory.create(@valid_attributes).should have(1).errors_on(:fullpath)
  end
end
