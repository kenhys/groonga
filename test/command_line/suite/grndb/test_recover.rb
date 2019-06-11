class TestGrnDBRecover < GroongaTestCase
  def setup
  end

  def test_normal_info_log
    groonga("table_create", "info", "TABLE_NO_KEY")
    grndb("recover", "--log-level", "info")
    assert_equal(<<-MESSAGE, normalize_groonga_log(File.read(@log_path)))
1970-01-01 00:00:00.000000|i| Recovering database: <#{@database_path}>
1970-01-01 00:00:00.000000|i| Recovered database: <#{@database_path}>
    MESSAGE
  end

  def test_orphan_inspect
    groonga("table_create", "inspect", "TABLE_NO_KEY")
    _id, _name, path, *_ = JSON.parse(groonga("table_list").output)[1][1]
    FileUtils.rm(path)
    result = grndb("recover")
    assert_equal("", result.error_output)
    result = grndb("check")
    assert_equal("", result.error_output)
  end

  def test_locked_database
    groonga("lock_acquire")
    error = assert_raise(CommandRunner::Error) do
      grndb("recover")
    end
    assert_equal(<<-MESSAGE, error.error_output)
Failed to recover database: <#{@database_path}>
object corrupt: <[db][recover] database may be broken. Please re-create the database>(-55)
    MESSAGE
    assert_equal(<<-MESSAGE, normalize_groonga_log(File.read(@log_path)))
1970-01-01 00:00:00.000000|e| [db][recover] database may be broken. Please re-create the database
1970-01-01 00:00:00.000000|e| Failed to recover database: <#{@database_path}>
1970-01-01 00:00:00.000000|e| object corrupt: <[db][recover] database may be broken. Please re-create the database>(-55)
    MESSAGE
  end

  sub_test_case("locked table") do
    def setup
      groonga("table_create", "Users", "TABLE_HASH_KEY", "ShortText")
      groonga("lock_acquire", "Users")

      _id, _name, path, *_ = JSON.parse(groonga("table_list").output)[1][1]
      @table_path = path
    end

    def test_default
      error = assert_raise(CommandRunner::Error) do
        grndb("recover")
      end
      assert_equal(<<-MESSAGE, error.error_output)
Failed to recover database: <#{@database_path}>
object corrupt: <[db][recover] table may be broken: <Users>: please truncate the table (or clear lock of the table) and load data again>(-55)
      MESSAGE
      assert_equal(<<-MESSAGE, normalize_groonga_log(File.read(@log_path)))
1970-01-01 00:00:00.000000|e| [db][recover] table may be broken: <Users>: please truncate the table (or clear lock of the table) and load data again
1970-01-01 00:00:00.000000|e| Failed to recover database: <#{@database_path}>
1970-01-01 00:00:00.000000|e| object corrupt: <[db][recover] table may be broken: <Users>: please truncate the table (or clear lock of the table) and load data again>(-55)
      MESSAGE
    end

    def test_force_truncate
      additional_path = "#{@table_path}.002"
      FileUtils.touch(additional_path)
      result = grndb("recover",
                     "--force-truncate",
                     "--log-level", "info")
      assert_equal(<<-MESSAGE, result.error_output)
[Users] Truncated broken object: <#{@table_path}>
[Users] Removed broken object related file: <#{additional_path}>
      MESSAGE
      assert_equal(<<-MESSAGE, normalize_groonga_log(File.read(@log_path)))
1970-01-01 00:00:00.000000|i| Recovering database: <#{@database_path}>
1970-01-01 00:00:00.000000|i| [io][remove] removed path: <#{@table_path}>
1970-01-01 00:00:00.000000|i| [Users] Truncated broken object: <#{@table_path}>
1970-01-01 00:00:00.000000|i| [Users] Removed broken object related file: <#{additional_path}>
1970-01-01 00:00:00.000000|i| Recovered database: <#{@database_path}>
      MESSAGE
    end
  end

  sub_test_case("locked data column") do
    def setup
      groonga("table_create", "Users", "TABLE_HASH_KEY", "ShortText")
      groonga("column_create", "Users", "age", "COLUMN_SCALAR", "UInt8")
      groonga("lock_acquire", "Users.age")

      users_column_list = JSON.parse(groonga("column_list", "Users").output)
      _id, _name, path, *_ = users_column_list[1][2]
      @column_path = path
    end

    def test_default
      error = assert_raise(CommandRunner::Error) do
        grndb("recover")
      end
      assert_equal(<<-MESSAGE, error.error_output)
Failed to recover database: <#{@database_path}>
object corrupt: <[db][recover] column may be broken: <Users.age>: please truncate the column (or clear lock of the column) and load data again>(-55)
      MESSAGE
      assert_equal(<<-MESSAGE, normalize_groonga_log(File.read(@log_path)))
1970-01-01 00:00:00.000000|e| [db][recover] column may be broken: <Users.age>: please truncate the column (or clear lock of the column) and load data again
1970-01-01 00:00:00.000000|e| Failed to recover database: <#{@database_path}>
1970-01-01 00:00:00.000000|e| object corrupt: <[db][recover] column may be broken: <Users.age>: please truncate the column (or clear lock of the column) and load data again>(-55)
      MESSAGE
    end

    def test_force_truncate
      additional_path = "#{@column_path}.002"
      FileUtils.touch(additional_path)
      result = grndb("recover",
                     "--force-truncate",
                     "--log-level", "info")
      assert_equal(<<-MESSAGE, result.error_output)
[Users.age] Truncated broken object: <#{@column_path}>
[Users.age] Removed broken object related file: <#{additional_path}>
      MESSAGE
      assert_equal(<<-MESSAGE, normalize_groonga_log(File.read(@log_path)))
1970-01-01 00:00:00.000000|i| Recovering database: <#{@database_path}>
1970-01-01 00:00:00.000000|i| [io][remove] removed path: <#{@column_path}>
1970-01-01 00:00:00.000000|i| [Users.age] Truncated broken object: <#{@column_path}>
1970-01-01 00:00:00.000000|i| [Users.age] Removed broken object related file: <#{additional_path}>
1970-01-01 00:00:00.000000|i| Recovered database: <#{@database_path}>
      MESSAGE
    end
  end

  sub_test_case("locked index column") do
    def setup
      groonga("table_create", "Users", "TABLE_HASH_KEY", "ShortText")
      groonga("column_create", "Users", "age", "COLUMN_SCALAR", "UInt8")

      groonga("table_create", "Ages", "TABLE_PAT_KEY", "UInt8")
      groonga("column_create", "Ages", "users_age",
              "COLUMN_INDEX", "Users", "age")

      values = [{"_key" => "alice", "age" => 29}]
      groonga("load",
              "--table", "Users",
              "--values",
              Shellwords.escape(JSON.generate(values)))
      groonga("truncate", "Ages")
      groonga("lock_acquire", "Ages.users_age")
    end

    def test_default
      result = grndb("recover")
      assert_equal("", result.error_output)

      select_result = groonga_select("Users", "--query", "age:29")
      n_hits, _columns, *_records = select_result[0]
      assert_equal([1], n_hits)
    end

    def test_force_truncate
      result = grndb("recover", "--force-truncate")
      assert_equal("", result.error_output)

      select_result = groonga_select("Users", "--query", "age:29")
      n_hits, _columns, *_records = select_result[0]
      assert_equal([1], n_hits)
    end
  end

  def test_force_clear_locked_database
    groonga("lock_acquire")
    result = grndb("recover", "--force-lock-clear", "--log-level", "info")
    assert_equal("", result.error_output)
    assert_equal(<<-MESSAGE, normalize_groonga_log(File.read(@log_path)))
1970-01-01 00:00:00.000000|i| Recovering database: <#{@database_path}>
1970-01-01 00:00:00.000000|i| Clear locked database: <#{@database_path}>
1970-01-01 00:00:00.000000|i| Recovered database: <#{@database_path}>
    MESSAGE
  end

  def test_force_clear_locked_table
    groonga("table_create", "Users", "TABLE_HASH_KEY", "ShortText")
    groonga("lock_acquire", "Users")
    result = grndb("recover", "--force-lock-clear", "--log-level", "info")
    assert_equal("", result.error_output)
    _id, _name, path, *_ = JSON.parse(groonga("table_list").output)[1][1]
    assert_equal(<<-MESSAGE, normalize_groonga_log(File.read(@log_path)))
1970-01-01 00:00:00.000000|i| Recovering database: <#{@database_path}>
1970-01-01 00:00:00.000000|i| [Users] Clear locked object: <#{path}>
1970-01-01 00:00:00.000000|i| Recovered database: <#{@database_path}>
    MESSAGE
  end

  def test_force_clear_locked_data_column
    groonga("table_create", "Users", "TABLE_HASH_KEY", "ShortText")
    groonga("column_create", "Users", "age", "COLUMN_SCALAR", "UInt8")
    groonga("lock_acquire", "Users.age")
    result = grndb("recover", "--force-lock-clear", "--log-level", "info")
    assert_equal("", result.error_output)
    _id, _name, path, *_ = JSON.parse(groonga("column_list Users").output)[1][2]
    assert_equal(<<-MESSAGE, normalize_groonga_log(File.read(@log_path)))
1970-01-01 00:00:00.000000|i| Recovering database: <#{@database_path}>
1970-01-01 00:00:00.000000|i| [Users.age] Clear locked object: <#{path}>
1970-01-01 00:00:00.000000|i| Recovered database: <#{@database_path}>
    MESSAGE
  end

  def test_force_clear_locked_index_column
    groonga("table_create", "Users", "TABLE_HASH_KEY", "ShortText")
    groonga("column_create", "Users", "age", "COLUMN_SCALAR", "UInt8")

    groonga("table_create", "Ages", "TABLE_PAT_KEY", "UInt8")
    groonga("column_create", "Ages", "users_age", "COLUMN_INDEX", "Users", "age")

    groonga("load",
            "--table", "Users",
            "--values",
            Shellwords.escape(JSON.generate([{"_key" => "alice", "age" => 29}])))
    groonga("truncate", "Ages")
    groonga("lock_acquire", "Ages.users_age")
    select_result = groonga_select("Users", "--query", "age:29")
    n_hits, _columns, *_records = select_result[0]
    assert_equal([0], n_hits)

    result = grndb("recover", "--force-lock-clear", "--log-level", "info")
    assert_equal("", result.error_output)
    _id, _name, path, *_ = JSON.parse(groonga("column_list Ages").output)[1][2]
    assert_equal(<<-MESSAGE, normalize_groonga_log(File.read(@log_path)))
1970-01-01 00:00:00.000000|i| Recovering database: <#{@database_path}>
1970-01-01 00:00:00.000000|i| [io][remove] removed path: <#{path}>
1970-01-01 00:00:00.000000|i| [io][remove] removed path: <#{path}.c>
1970-01-01 00:00:00.000000|i| [ii][builder][fin] removed path: <#{path}XXXXXX>
1970-01-01 00:00:00.000000|i| Recovered database: <#{@database_path}>
    MESSAGE

    select_result = groonga_select("Users", "--query", "age:29")
    n_hits, _columns, *_records = select_result[0]
    assert_equal([1], n_hits)
  end

  def test_empty_file
    groonga("table_create", "Users", "TABLE_HASH_KEY", "ShortText")
    _id, _name, path, *_ = JSON.parse(groonga("table_list").output)[1][1]
    FileUtils.rm(path)
    FileUtils.touch(path)
    error = assert_raise(CommandRunner::Error) do
      grndb("recover")
    end
    assert_equal(<<-MESSAGE, error.error_output)
Failed to recover database: <#{@database_path}>
incompatible file format: <[io][open] file size is too small: <0>(required: >= 64): <#{path[0..68]}>(-65)
    MESSAGE
    assert_equal(<<-MESSAGE, normalize_groonga_log(File.read(@log_path)))
1970-01-01 00:00:00.000000|e| [io][open] file size is too small: <0>(required: >= 64): <#{path}>
1970-01-01 00:00:00.000000|e| grn_ctx_at: failed to open object: <256>(<Users>):<48>(<table:hash_key>)
1970-01-01 00:00:00.000000|e| Failed to recover database: <#{@database_path}>
1970-01-01 00:00:00.000000|e| incompatible file format: <[io][open] file size is too small: <0>(required: >= 64): <#{path[0..68]}>(-65)
    MESSAGE
  end

  def test_broken_id
    groonga("table_create", "Users", "TABLE_HASH_KEY", "ShortText")
    _id, _name, path, *_ = JSON.parse(groonga("table_list").output)[1][1]
    data = File.binread(path)
    data[0] = "X"
    File.binwrite(path, data)
    error = assert_raise(CommandRunner::Error) do
      grndb("recover")
    end
    assert_equal(<<-MESSAGE, error.error_output)
Failed to recover database: <#{@database_path}>
incompatible file format: <failed to open: format ID is different: <#{path[0..85]}>(-65)
    MESSAGE
    assert_equal(<<-MESSAGE, normalize_groonga_log(File.read(@log_path)))
1970-01-01 00:00:00.000000|e| failed to open: format ID is different: <#{path}>: <GROONGA:IO:00001>
1970-01-01 00:00:00.000000|e| grn_ctx_at: failed to open object: <256>(<Users>):<48>(<table:hash_key>)
1970-01-01 00:00:00.000000|e| Failed to recover database: <#{@database_path}>
1970-01-01 00:00:00.000000|e| incompatible file format: <failed to open: format ID is different: <#{path[0..85]}>(-65)
    MESSAGE
  end

  def test_broken_type_hash
    groonga("table_create", "Users", "TABLE_HASH_KEY", "ShortText")
    _id, _name, path, *_ = JSON.parse(groonga("table_list").output)[1][1]
    data = File.binread(path)
    data[16] = "\0"
    File.binwrite(path, data)
    error = assert_raise(CommandRunner::Error) do
      grndb("recover")
    end
    assert_equal(<<-MESSAGE, error.error_output)
Failed to recover database: <#{@database_path}>
invalid format: <[table][hash] file type must be 0x30: <0000>>(-54)
    MESSAGE
    assert_equal(<<-MESSAGE, normalize_groonga_log(File.read(@log_path)))
1970-01-01 00:00:00.000000|e| [table][hash] file type must be 0x30: <0000>
1970-01-01 00:00:00.000000|e| grn_ctx_at: failed to open object: <256>(<Users>):<48>(<table:hash_key>)
1970-01-01 00:00:00.000000|e| Failed to recover database: <#{@database_path}>
1970-01-01 00:00:00.000000|e| invalid format: <[table][hash] file type must be 0x30: <0000>>(-54)
    MESSAGE

  end

  def test_broken_type_array
    groonga("table_create", "Logs", "TABLE_NO_KEY")
    _id, _name, path, *_ = JSON.parse(groonga("table_list").output)[1][1]
    data = File.binread(path)
    data[16] = "\0"
    File.binwrite(path, data)
    error = assert_raise(CommandRunner::Error) do
      grndb("recover")
    end
    messages = <<-MESSAGE
Failed to recover database: <#{@database_path}>
invalid format: <[table][array] file type must be 0x33: <0000>>(-54)
    MESSAGE
    assert_equal(messages, error.error_output)
    assert_equal(<<-MESSAGE, normalize_groonga_log(File.read(@log_path)))
1970-01-01 00:00:00.000000|e| [table][array] file type must be 0x33: <0000>
1970-01-01 00:00:00.000000|e| grn_ctx_at: failed to open object: <256>(<Logs>):<51>(<table:no_key>)
1970-01-01 00:00:00.000000|e| Failed to recover database: <#{@database_path}>
1970-01-01 00:00:00.000000|e| invalid format: <[table][array] file type must be 0x33: <0000>>(-54)
    MESSAGE
  end
end
