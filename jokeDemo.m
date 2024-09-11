% LM Studio Implementation using MATLAB example
% Ahmad Faisal Ayob, 11 Sept. 2024
% Load the model, check on the model lines, that this example is using xtuner/llava-phi-3-mini-gguf/llava-phi-3-mini-f16.gguf
% Run the LM Studio Server
% Define the URL
url = 'http://127.0.0.1:1234/v1/chat/completions';

% Prepare the headers
headers = {'Content-Type', 'application/json'};

% Prepare the request body
body = struct(...
    'model', 'xtuner/llava-phi-3-mini-gguf/llava-phi-3-mini-f16.gguf', ...
    'messages', {{...
        struct('role', 'system', 'content', 'You are a helpful jokester.'), ...
        struct('role', 'user', 'content', 'Tell me a joke.')...
    }}, ...
    'response_format', struct(...
        'type', 'json_schema', ...
        'json_schema', struct(...
            'name', 'joke_response', ...
            'strict', 'true', ...
            'schema', struct(...
                'type', 'object', ...
                'properties', struct(...
                    'joke', struct('type', 'string')...
                ), ...
                'required', {{'joke'}}...
            )...
        )...
    ), ...
    'temperature', 0.7, ...
    'max_tokens', 50, ...
    'stream', false);

% Convert the body to JSON
jsonBody = jsonencode(body);

% Set options with increased timeout
options = weboptions('RequestMethod', 'post', ...
                     'HeaderFields', headers, ...
                     'ContentType', 'json', ...
                     'Timeout', 30);

% Make the HTTP request with error handling
try
    response = webwrite(url, jsonBody, options);
    
    % Display the full response
    disp('Full response:');
    disp(response);

    % Extract and display the joke
    if isfield(response, 'choices') && ~isempty(response.choices)
        % The content might be a string containing JSON
        content = response.choices(1).message.content;
        try
            % Try to parse the content as JSON
            joke_struct = jsondecode(content);
            if isfield(joke_struct, 'joke')
                disp('The joke is:');
                disp(joke_struct.joke);
            else
                disp('Joke field not found in the parsed content.');
                disp('Parsed content:');
                disp(joke_struct);
            end
        catch
            % If parsing fails, display the content as is
            disp('Could not parse the content as JSON. Raw content:');
            disp(content);
        end
    else
        disp('No choices found in the response.');
    end
catch ME
    % Error handling
    disp('An error occurred:');
    disp(ME.message);
    
    % Additional error information
    if strcmp(ME.identifier, 'MATLAB:webservices:Timeout')
        disp('The request timed out. Please check if the server is running and accessible.');
    elseif strcmp(ME.identifier, 'MATLAB:webservices:UnknownHost')
        disp('Could not connect to the server. Please check your network connection and the server address.');
    else
        disp('For more details, use the "getReport" function with the error object.');
    end
end
