function optoTransl = rotoTranslateCoord(coord, R_matrix, base)
    optoTransl = (coord-base)*R_matrix;
end