function [content] = analyzeImage(message, imagePath)

    % LM Studio Implementation using MATLAB example
    % Vision Demo using xtuner/llava-phi-3-mini-gguf/llava-phi-3-mini-f16.gguf
    % Copyright 2024 Ahmad Faisal Ayob, VSG Labs Sdn Bhd, 11 Sept. 2024

    % Example call to the function
    % message = 'What is this image?'; 
    % imagePath ='C:\Github\LM-Studio-MATLAB-Call\parrot.jpeg'; [response, token] =
    % analyzeImage(message, imagePath);

    % Check if no arguments are provided, then set default example values
    if nargin == 0
        disp('No arguments provided. Running the example with default values.');
        message = 'What is this image?';
        imagePath = 'C:\Github\LM-Studio-MATLAB-Call\parrot.jpeg';
    end

    % Load the model, check on the model lines, that this example is using
    % xtuner/llava-phi-3-mini-gguf/llava-phi-3-mini-f16.gguf
    % Run the LM Studio Server
    % Define the URL
    url = 'http://127.0.0.1:1234/v1/chat/completions';

    % Prepare the headers
    headers = {'Content-Type', 'application/json'};

    % Step 1: Load the image
    img = imread(imagePath);

    % Step 2: Resize the image to have a maximum width of 200 pixels, maintaining the aspect ratio
    [height, width, ~] = size(img);  % Get the image dimensions

    if width > 200
        scaleFactor = 200 / width;  % Calculate the scaling factor based on width
        img = imresize(img, scaleFactor);  % Resize the image while maintaining the aspect ratio
    end

    % Step 3: Write the resized image to a temporary file in a compressed format (JPEG)
    [~,~,ext] = fileparts(imagePath);  % Get the file extension (e.g., '.png')
    tempFileName = ['temp_image', ext];
    imwrite(img, tempFileName);

    % Step 3: Read the image file as binary data
    fid = fopen(tempFileName, 'rb');
    imageData = fread(fid, '*uint8');
    fclose(fid);

    % Optional: Show the image
    imshow(img);

    % Step 4: Convert the binary data to Base64 string
    base64Image = matlab.net.base64encode(imageData);

    % Step 5: Prepare the request body with a dynamic query (message) and the Base64 image
    body = struct(...
        'model', 'xtuner/llava-phi-3-mini-gguf/llava-phi-3-mini-f16.gguf', ...
        'messages', {{...
            struct('role', 'user', ...
                   'content', {{...
                       struct('type', 'text', 'text', message), ...  % Pass custom message
                       struct('type', 'image_url', ...
                              'image_url', struct('url', ['data:image/', ext(2:end), ';base64,', base64Image]))...
                   }})...
        }}, ...
        'temperature', 0.7, ...
        'max_tokens', -1, ...
        'stream', false);

    % Step 6: Convert the body to JSON
    jsonBody = jsonencode(body);

    % Set options with increased timeout
    options = weboptions('RequestMethod', 'post', ...
                         'HeaderFields', headers, ...
                         'ContentType', 'json', ...
                         'Timeout', 180); % Increased timeout for image processing

    % Step 7: Make the HTTP request with error handling
    try
        response = webwrite(url, jsonBody, options);
        
        % Display the full response
        % disp('Full response:');
        % disp(response);

        % Extract and display the content
        if isfield(response, 'choices') && ~isempty(response.choices)
            content = response.choices(1).message.content;
            % disp('Response content:');
            % disp(content);
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

end
