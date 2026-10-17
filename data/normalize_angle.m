function res = normalize_angle(angle)
    while (angle > pi)
        angle = angle - 2.0 * pi;
    end
    while (angle < -pi)
        angle = angle + 2.0 * pi;
    end
    res = angle;
end
