x = [1:500]';
m = 2;
b = 5;
y = m*x + b;
y = y + randn(size(x));
A = [x ones(size(x))];
mb_estimate = inv(A'*A)*A'*y;
mb_estimate = A\y;
mb_estimate = pinv(A)*y;
plot(mb_estimate)
syms x y
a = 10; b = 20; c = 30;
z = a*x+b*y+c;
z = z + randn(size(x)) + randn(size(y));
ezmesh(z)
