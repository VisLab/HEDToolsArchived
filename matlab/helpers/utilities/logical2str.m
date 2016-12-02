% Converts a logical to a string
function str = logical2str(value)
if value
    str = 'true';
else
    str = 'false';
end
end % logical2str