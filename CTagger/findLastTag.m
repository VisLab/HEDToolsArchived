function str = findLastTag(text, position)
insideStr = false;
str = '';
for start = position:-1:1
    if ~isspace(text(start)) && ~any(strcmpi({'(',')','"'}, text(start)))
        insideStr = true;
        str = [str text(start)];
    elseif insideStr
        break;
    end
end
str = fliplr(str);
end
