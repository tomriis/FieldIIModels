function angles_r = get_ellipse_angle_spacing(a,b, N)
        p = ellipse_perimeter(a,b);
        res = 30000;
        arc_length = p/N;
        X = linspace(-pi,pi,res);
        Y = sqrt(a^2*sin(X).^2 + b^2*cos(X).^2);
        
        Y = zeros(length(X),1);
        for i = 2:length(X)
            Y(i) = sqrt((a*cos(X(i))-a*cos(X(i-1)))^2+(b*sin(X(i))-b*sin(X(i-1)))^2);
        end
        arc_lengths = zeros(length(X),1);
        for i = 1:length(X)
            q = sum(Y(1:i));
            arc_lengths(i) = q;
        end
        angles_r = zeros(N,1);
        for i = 0:N-1
            len = arc_length*i;
            [~,ind] = min(abs(arc_lengths-len));
            angles_r(i+1) = X(ind);
        end
%         
%         distances=zeros(length(angles_r),1);
%         wrapN = @(x, n) (1 + mod(x-1, n));
%         for i =1:length(angles_r)
%             
%             tj = angles_r(wrapN(i+1,N));
%             ti = angles_r(i);
%             dist_neighbor_j = sqrt((a*cos(tj)-a*cos(ti))^2+(b*sin(tj)-b*sin(ti))^2);
%             distances(i)=dist_neighbor_j;
%         end
%         disp(strcat('Mean ',num2str(mean(distances))));
%         disp(strcat('STD ',num2str(std(distances))));
%         figure; histogram(distances)
end