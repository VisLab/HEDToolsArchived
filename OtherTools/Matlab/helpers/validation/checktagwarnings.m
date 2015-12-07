function warnings = checktagwarnings(Maps, original, canonical)
warnings = '';
warnings = [warnings checkcaps(original)];
warnings = [warnings checkslashes(original)];
end % checktagwarnings