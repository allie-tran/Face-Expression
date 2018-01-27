function d = distance(h, X)
for i=1:size(X,1)
    d(i,1) = sum((h-X(i,:)).^2./(h+X(i,:)));
end
end
