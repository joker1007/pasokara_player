# _*_ coding: utf-8 _*_

module DbErrorHelper
  def test_for_db_error(&block)
    database_threw_error = false
    other_error = false
    begin
      yield
    rescue ActiveRecord::StatementInvalid
      database_threw_error = true
    rescue Exception
      other_error = true
      puts $!
      puts $@
    end
    database_threw_error.should be_true
    other_error.should be_false
  end
end
