
create
    database user_management;
use
    user_management;
create table roles
(
    id   int auto_increment primary key,
    name varchar(20) not null
);

create table users
(
    id          int auto_increment primary key,
    name        varchar(50) not null unique ,
    password    varchar(20) not null,
    address     varchar(250),
    phone       varchar(20),
    dateOfBirth datetime,
    status      bit

);

create table user_role
(
    user_id int,
    role_id int,
    foreign key (user_id) references users (id),
    foreign key (role_id) references roles (id)
);

# Đăng ký
drop procedure if exists RegisterUser;
delimiter //
CREATE PROCEDURE RegisterUser(
    IN p_name VARCHAR(50),
    IN p_password varchar(20),
    IN p_address VARCHAR(250),
    IN p_phone VARCHAR(20),
    IN p_dateOfBirth DATETIME,
    IN p_status BIT,
    IN p_role_id int
)
BEGIN
    INSERT INTO users (name, password, address, phone, dateOfBirth, status)
    VALUES (p_name, p_password, p_address, p_phone, p_dateOfBirth, p_status);

    SET @user_id = LAST_INSERT_ID();

    INSERT INTO user_role (user_id, role_id) VALUES (@user_id, p_role_id);
END //
delimiter ;


# Đăng nhập
drop procedure if exists UserLogin;
delimiter //
CREATE PROCEDURE UserLogin(
    IN p_name VARCHAR(50),
    IN p_password VARCHAR(20)
)
BEGIN
    DECLARE user_id INT;

    SELECT u.id
    INTO user_id
    FROM users u
                 WHERE u.name = p_name
      AND u.password = p_password;

    SELECT user_id AS 'User ID';
END //
delimiter ;

# lấy về tất cả user có role là người dùng
drop procedure if exists GetUsersWithUserRole;
delimiter //
CREATE PROCEDURE GetUsersWithUserRole()
BEGIN
    SELECT u.id, u.name, u.address, u.phone, u.dateOfBirth, u.status
    FROM users u
             JOIN user_role ur ON u.id = ur.user_id
             JOIN roles r ON ur.role_id = r.id
    WHERE r.name = 'User';
END //
delimiter ;

call RegisterUser('Hung','11111111','HN','0335505252','1998-12-04',true,1);
call RegisterUser('Hoa','123','HP','01314','1985-12-04',false,2);
call RegisterUser('Thanh','888888','TH','12345','1995-02-04',true,3);

call UserLogin('Hung','11111111');

call GetUsersWithUserRole();