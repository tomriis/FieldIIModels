function angles_r  = get_ellipse_angle_spacing(a,b, N,thetaRange)
        p = ellipse_perimeter(a,b,thetaRange);
        res = 30000;
        arc_length = p/N;
        X = linspace(thetaRange(1),thetaRange(2),res);

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
        for i = 1:N
            len = arc_length*(i-1/2);
            [~,ind] = min(abs(arc_lengths-len));
            angles_r(i) = X(ind);
        end
         
end