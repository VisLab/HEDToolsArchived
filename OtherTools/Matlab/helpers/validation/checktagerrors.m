function [errors, warnings, extensions] = ...
    checktagerrors(Maps, original, canonical, extensionAllowed)
errors = '';
errors = [errors, checkrequired(Maps, canonical)];
errors = [errors, checkrequirechild(Maps, original, canonical)];
[takeValueErrors, ~, warnings] = ...
    checktakesvalue(Maps, original, canonical);
errors = [errors takeValueErrors];
errors = [errors, checktildes(original)];
errors = [errors, checkunique(Maps, original, canonical)];
[validErrors, extensions] = checkvalid(Maps, original, canonical, ...
    extensionAllowed);
errors = [errors validErrors];
end % checktagerrors