create database transaction;
use transaction;

create table users(
    id int primary key auto_increment,
    name varchar(50) not null ,
    money int check ( money>0 ),
    address varchar(50),
    phone varchar(20),
    dateOfBirth datetime,
    status bit
);

create table transfer(
    sender_id int,
    receiver_id int,
    money bigint,
    foreign key (sender_id) references users(id),
    foreign key (receiver_id) references users(id),
    check ( sender_id!=receiver_id )
);

# Tạo transaction (phiên giao dịnh) khi gửi tiền đến tài khoản người nếu vượt quá số tiền trong tài khoản thì sẽ (rollback) trở lại vị trí ban đầu khi bắt đầu giao dịnh
delimiter //
create procedure MakeTransfer(
    in p_sender_id int,
    in p_receiver_id int,
    in p_money bigint
)
begin
    declare sender_balance int;
    start transaction;
    select money into sender_balance from users where id=p_sender_id;
    if sender_balance>=p_money then
        UPDATE users SET money = money - p_money WHERE id = p_sender_id;

        UPDATE users SET money = money + p_money WHERE id = p_receiver_id;

        INSERT INTO transfer (sender_id, receiver_id, money) VALUES (p_sender_id, p_receiver_id, p_money);

        COMMIT;
    ELSE
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không đủ tiền giao dịch';
    END IF;
end //
delimiter ;

call MakeTransfer(1,2,50);