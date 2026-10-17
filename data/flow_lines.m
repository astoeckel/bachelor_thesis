function flow_lines(d, alpha, psi, r)
    T = @(d, alpha, psi) [ ...
       [cos(psi); -sin(psi); 0], ...
       [sin(psi); cos(psi); 0], ...
       [0; 0; 1], ...
       [d * cos(alpha); d * sin(alpha); 0]];
    P = @(v) [...
       atan2(v(2), v(1)); ...
       atan2(v(3), sqrt(v(1)^2 + v(2)^2))];
    PInv = @(beta, gamma, r) [...
        r * cos(beta); ...
        r * sin(beta); ...
        r * tan(gamma); ...
        1];
    u = @(d, alpha, psi, r, beta, gamma) ...
        P(T(d, alpha, psi)*PInv(beta, gamma, r)) - [beta; gamma];
    
    flowVector1 = @(beta, gamma) u(d, 0, 0, r, beta - psi - alpha, gamma) - [psi; 0];
    flowVector2 = @(beta, gamma) u(d, alpha, psi, r, beta, gamma);
    elevation = 2*pi / 180 * 30;
    X = [];
    Y = [];
    U1 = [];
    V1 = [];
    U2 = [];
    V2 = [];
    for beta = 0:0.2:2*pi
      for gamma = 0:0.2:elevation
        v1 = flowVector1(beta, gamma);
        v2 = flowVector2(beta, gamma);
        X = [X, beta];
        Y = [Y, gamma];
        U1 = [U1, normalize_angle(v1(1))];
        V1 = [V1, normalize_angle(v1(2))];
        U2 = [U2, normalize_angle(v2(1))];
        V2 = [V2, normalize_angle(v2(2))];
      end
    end
    close all
    quiver(X, Y, U1, V1, 'AutoScale', 'off', 'Color', [0 0.25 0.75]);
    hold on
    quiver(X, Y, U2, V2, 'AutoScale', 'off', 'Color', [0.25 0.75 0.0]);
    axis equal;
    axis([-0.1, 2*pi+0.1, -0.1, elevation+0.1]);
    ylabel('\gamma');
    xlabel('\beta');
#    set(gca, 'FontName', 'Times');
#    print('-dpdf', sprintf('flow_lines_d%1.2f_alpha%1.2f_psi%1.2f_r%1.2f.pdf', d, alpha, psi, r));
end
