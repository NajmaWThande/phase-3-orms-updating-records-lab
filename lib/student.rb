require_relative "../config/environment.rb"

class Student
attr_accessor :name, :grade
attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

    def initialize(id=nil, name, grade)
      @id = id
      @name = name
      @grade = grade
    end
  
    def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS students(
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade TEXT
        )
      SQL
      DB[:conn].execute(sql)
    end
  
    def save 
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  
    def self.create(name:, grade:)
      student = Student.new(name, grade)
      student.save
      student
    end
  
    def self.drop_table
      sql = "DROP TABLE IF EXISTS students"
      DB[:conn].execute(sql)
    end
  
    def self.find_by_name(name)
      sql = "SELECT * FROM students WHERE name = ? LIMIT 1"
      result = DB[:conn].execute(sql, name)
      if result.empty?
        return nil
      else
        row = result[0]
        Student.new_from_db(row)
      end
    end
  
    def self.new_from_db(row)
      id = row[0]
      name = row[1]
      grade = row[2]
      Student.new(id, name, grade)
    end
  
    def update
      sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end
  end
  