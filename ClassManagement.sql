create database class_management;
use class_management;

create table Class
(
    classId   int auto_increment primary key,
    className varchar(20) not null unique,
    startDate datetime,
    status    bit default true
);

create table Student
(
    studentId   int auto_increment primary key,
    studentName varchar(50) not null,
    address     varchar(255),
    phone       varchar(15),
    status      bit default true,
    classId     int,
    foreign key (classId) references Class (classId)
);

create table Subject
(
    subId   int auto_increment primary key,
    subName varchar(20) not null,
    credit  tinyint default 1,
    status  bit     default true
);

create table Mark
(
    markId     int auto_increment primary key,
    sub_id     int,
    student_id int,
    mark       int check ( mark between 0 and 10),
    examTime   datetime
);

# 	Tạo 4 store procedure để them dữ liệu vào các bảng “Class”, “Student”, “Mark”, “Subject”
delimiter //
create procedure InsertClass(
    in p_name varchar(20),
    in p_start datetime,
    in p_status bit
)
begin
    insert into Class(className, startDate, status) values (p_name, p_start, p_status);
end //
delimiter ;

DELIMITER //
CREATE PROCEDURE InsertStudent(
    IN p_name VARCHAR(50),
    IN p_address VARCHAR(255),
    IN p_phone VARCHAR(15),
    IN p_status BIT,
    IN p_classId INT
)
BEGIN
    INSERT INTO Student (studentName, address, phone, status, classId)
    VALUES (p_name, p_address, p_phone, p_status, p_classId);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE InsertSubject(
    IN p_name VARCHAR(20),
    IN p_credit TINYINT,
    IN p_status BIT
)
BEGIN
    INSERT INTO Subject (subName, credit, status)
    VALUES (p_name, p_credit, p_status);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE InsertMark(
    IN p_sub_id INT,
    IN p_student_id INT,
    IN p_mark INT,
    IN p_examTime DATETIME
)
BEGIN
    INSERT INTO Mark (sub_id, student_id, mark, examTime)
    VALUES (p_sub_id, p_student_id, p_mark, p_examTime);
END //
DELIMITER ;
# 	Tạo store procedure lấy ra danh sách học sinh có điểm cao nhất môn “Hóa Học” sắp xếp theo chiều giảm dần
delimiter //
create procedure SortStudentChemistryScore()
begin
    select student.studentId, studentName, subName, mark
    from Student
             join Mark on student.studentId = mark.student_id
             join subject on mark.sub_id = subject.subId
    where subName = 'Hóa học'
    order by mark desc;
end //
delimiter ;

# 	Tạo store procedure lấy ra danh sách môn học được nhiều sinh viên thị nhất sắp xếp theo chiều giảm dần
delimiter //
create procedure FindSubjectWithMostExamParticipants()
begin
    select s.subId, s.subName, count(distinct student_id) as 'Total students'
    from subject s
             join mark m on s.subId = m.sub_id

    group by s.subId, s.subName
    having count(distinct student_id) = (select max(Subquery.TotalStudents)
                                         from (select count(distinct m.student_id) as TotalStudents
                                               from subject s
                                                        join mark m on s.subId = m.sub_id
                                               group by s.subId, s.subName) as Subquery);
end //
delimiter ;

# Chạy thử
call InsertSubject('Toán', 3, true);
call InsertClass('A1', '2010-09-05', true);
call InsertStudent('Hoa', 'HN', '123', true, 1);
call InsertMark(1, 1, 8, '2010-10-31');

call SortStudentChemistryScore();
call FindSubjectWithMostExamParticipants();