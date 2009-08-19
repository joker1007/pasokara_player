require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PasokaraFile do
  fixtures :directories, :pasokara_files

  before(:each) do
    @valid_attributes = {
      :name => "拝啓ラブサマー.mp4",
      :fullpath => "E:\\pasokara\\C&C\\拝啓ラブサマー.mp4",
      :rootpath => "E:\\pasokara",
    }

    @cool_and_create = directories(:cool_and_create)
  end

  it "適切なパラメーターで作成されること" do
    PasokaraFile.create!(@valid_attributes)
  end

  it "ディレクトリに含まれることができる" do
    pasokara = @cool_and_create.pasokara_files.create!(@valid_attributes)
    pasokara.directory.should == @cool_and_create
  end

  it "フルパスが同一のファイルは作成できない" do
    PasokaraFile.create(@valid_attributes)
    PasokaraFile.create(@valid_attributes).should have(1).errors_on(:fullpath)
  end

  it "Directory.structメソッドで、指定したディレクトリ以下を再帰的に取得し、データベースを構築すること" do
    Directory.struct("/var/www/virtualhtml/pasokara/shared/pasokara")
    PasokaraFile.find(:all).length.should >= 50
    PasokaraFile.find(:first, :conditions => ["fullpath LIKE ?", "/var/www/virtualhtml/pasokara/shared/pasokara%"]).directory.should be_true
    PasokaraFile.find(:all, :conditions => ["rootpath = ?", "/var/www/virtualhtml/pasokara/shared/pasokara"]).length.should >= 50
  end
end
