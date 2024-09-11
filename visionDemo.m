% LM Studio Implementation using MATLAB example
% Vision Demo using xtuner/llava-phi-3-mini-gguf/llava-phi-3-mini-f16.gguf
% Ahmad Faisal Ayob, 11 Sept. 2024
% Load the model, check on the model lines, that this example is using xtuner/llava-phi-3-mini-gguf/llava-phi-3-mini-f16.gguf
% Run the LM Studio Server
% Define the URL
% Define the URL
url = 'http://127.0.0.1:1234/v1/chat/completions';

% Prepare the headers
headers = {'Content-Type', 'application/json'};

% Base64 encoded image string (already provided in the curl command)
base64Image = 'iVBORw0KGgoAAAANSUhEUgAAABsAAAAbCAYAAACN1PRVAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAQ2SURBVEhL3ZVrTBxVFMf/d2f2vcsCWxZYZKVQW4vVUmmtNpgaSSA1NUWpkFhpWkOwxsZa0WpqjMYXaTQR4wdjSttQ2tDaGIRqa5HWVmwFYgwasRhoeRipi1BWdpd9sDvjndmBZbzgt/ZDf1927jl3zv+ec8+ZJbcvLRBxk9AovzeFW1ds3jtzcQ6YHXcCQR+EsQEQuwvEaAPvGUCKdhK8cRq/BP1wTxKIyttjj78Iw9VuWLrPxQzzwIhtwb1wl+2FL8GGTcfq8U9SMlo3liK7vxdFJz+HzhBC/s52WF0e+ENAxxUeX/fwaPAWgBu/Bu3ffyiRWJgyuktfgc9KhY7XY8psUQnpzQGs3nVBFpIw64HC3AjefyKIrk1nsQxD4ECwf2yd7P8vjNi0XhcTMllw+rFyZA5dlYVMiT6s2X0BloxJZacal13EZzt82K5PRc60RbGqYcpYoy1BxJqM5rIKZAwPYkPzcSQ6xpH3zCUYkgPKrnkIcQi9W4zosA3b7ZfQyU0ojjhMZj5rAk5u3jIrZL9tlJbuu/8XktBGwT/UB1NtE5YUuBWjGkbsYnEJFrn/koUc2SNYVtmOs70RNHcQTHjVjRukDdLWDXzRQbvRB3AP9wGJQTy1NqzsUMOUseSR/ShuaYJz+SAySjvxXJ0G3ilApxURFQg+rooiKxWY9It49hMe417aKAYqTON/WBlFID0Hd4lXsOZtKyamiBI1BpPZhlPHkLmyH/c83YnuYRHjtB+OVkdx6HlB9v/QGwvw86AGI9eBw7sjOPwCFUldjELdAeQF67Ak3Ii0FVnyvrkwmTXlu7Cq7FfqiZXJQ7NKS4r5rtMy8vR4CWaCUFg6CIFzUcxX5K/B3TSjt8xHcSp6Hyp81UirqcDs1FOYzBxFPbKQhIHO0YyQRLKVyELSIU7/RGDUxwN5uQSsNfSjPPw6zCSIMG+GoKP1nQMjNuJhTAx/jgMftXDYWsvLGUq8xh9BRXgvOoXlGBZTYZoagyak7mAmcp87bvommo+sQKOyipPjBHY9KsAXIDjjX4HzQh4smgDOGPagmj+BPeEq2LpalN1xmDvbvDqMD8qC8vOokIQWYR0q+a/k9Qw9Q8DOT3mIJjPIS28o1hgcBDzg/x4N+9gPMiPGa0S0VvuQnaIyqxDppTd8q8GhNg6NL0dU9ypRVW9Ea49WWcVhyhihs/TOl/GLFX530KGinTKH34aJLHSHU0RKgvpQPw5yaLvMCklwiXbXm8rzLANjHDKTosh1CgjXrocm3QuSRqdXIcUmYlWOiCfXC9Dr4oM7FSbYWmei46Ie5hkWbL0DR9Jx8dUHIU6YoMm9plhjEEKwcrH05YgHPd/L4f59SejXuBQLy4JihUEnPKNGlCe342AXT7Nlt0p/nucu89jRYMS2g2aMLC2Ee9t7ipeFaZAbyYKZ3QhuVTHgX54yfufoA1ofAAAAAElFTkSuQmCC';

% Prepare the request body
body = struct(...
    'model', 'xtuner/llava-phi-3-mini-gguf/llava-phi-3-mini-f16.gguf', ...
    'messages', {{...
        struct('role', 'user', ...
               'content', {{...
                   struct('type', 'text', 'text', 'What is this image?'), ...
                   struct('type', 'image_url', ...
                          'image_url', struct('url', ['data:image/png;base64,', base64Image]))...
               }})...
    }}, ...
    'temperature', 0.7, ...
    'max_tokens', -1, ...
    'stream', false);

% Convert the body to JSON
jsonBody = jsonencode(body);

% Set options with increased timeout
options = weboptions('RequestMethod', 'post', ...
                     'HeaderFields', headers, ...
                     'ContentType', 'json', ...
                     'Timeout', 60); % Increased timeout for image processing

% Make the HTTP request with error handling
try
    response = webwrite(url, jsonBody, options);
    
    % Display the full response
    disp('Full response:');
    disp(response);

    % Extract and display the content
    if isfield(response, 'choices') && ~isempty(response.choices)
        content = response.choices(1).message.content;
        disp('Response content:');
        disp(content);
    else
        disp('No choices found in the response.');
    end
catch ME
    % Error handling
    disp('An error occurred:');
    disp(ME.message);
    
    % Additional error information
    if strcmp(ME.identifier, 'MATLAB:webservices:Timeout')
        disp('The request timed out. The image processing might require more time.');
    elseif strcmp(ME.identifier, 'MATLAB:webservices:UnknownHost')
        disp('Could not connect to the server. Please check your network connection and the server address.');
    else
        disp('For more details, use the "getReport" function with the error object.');
    end
end


% Decode Base64 to a byte array
byteArray = matlab.net.base64decode(base64Image);

% Convert the byte array to an image
% Write the byte array to a temporary file and read it back as an image
tempFileName = 'temp_image.png';  % Or use jpg, based on the image type
fid = fopen(tempFileName, 'w');
fwrite(fid, byteArray, 'uint8');
fclose(fid);

% Step 3: Read and display the image
img = imread(tempFileName);
imshow(img);

% Optionally delete the temporary file
delete(tempFileName);

