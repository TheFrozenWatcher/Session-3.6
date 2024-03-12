create database shop_management;
use shop_management;

create table users
(
    id          int primary key auto_increment,
    name        varchar(50) not null,
    address     varchar(255),
    phone       varchar(20),
    dateOfBirth datetime,
    status      bit
);

create table products
(
    id     int primary key auto_increment,
    name   varchar(50) not null,
    price  bigint default 0,
    stock  int check ( stock >= 0 ),
    status bit
);

create table shopping_cart
(
    id         int primary key auto_increment,
    user_id    int,
    product_id int,
    quantity   int check ( quantity > 0 ),
    totalPrice bigint,
    foreign key (user_id) references users(id),
    foreign key (product_id) references products(id)
);

DELIMITER //
CREATE TRIGGER update_shopping_cart_total_price
    BEFORE INSERT ON shopping_cart
    FOR EACH ROW
BEGIN
    SET NEW.totalPrice = (SELECT price FROM products WHERE id = NEW.product_id) * NEW.quantity;
END //
DELIMITER ;

# 	Tạo Trigger khi thay đổi giá của sản phẩm thì amount (tổng giá) cũng sẽ phải cập nhật lại
DELIMITER //
CREATE TRIGGER update_total_price
    AFTER UPDATE ON products
    FOR EACH ROW
BEGIN
    UPDATE shopping_cart
    SET totalPrice = NEW.price * quantity
    WHERE product_id = NEW.id;
END //
DELIMITER ;

# 	Tạo trigger khi xóa product thì những dữ liệu ở bảng shopping_cart có chứa product bị xóa thì cũng phải xóa theo
DELIMITER //
CREATE TRIGGER delete_shopping_cart_entries
    AFTER DELETE ON products
    FOR EACH ROW
BEGIN
    DELETE FROM shopping_cart
    WHERE product_id = OLD.id;
END //
DELIMITER ;
# 	Khi thêm một tạo một shopping_cart với số lượng n thì bên product cũng sẽ phải trừ đi số lượng n
DELIMITER //
CREATE TRIGGER update_product_stock
    AFTER INSERT ON shopping_cart
    FOR EACH ROW
BEGIN
    UPDATE products
    SET stock = stock - NEW.quantity
    WHERE id = NEW.product_id;
END //
DELIMITER ;


