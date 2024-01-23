function outputText = inferenceLMStudio(userString)
%INFERENCELMSTUDIO  Calling LM Studio (v0.2.10) from MATLAB using curlCommand
%A demonstration of MATLAB call to LM Studio HTTP server that behaves like OpenAI's API
%   Examples/Steps:
%       1: Load Model in LM Studio
%       2: Navigate LM Studio and find "Local Inference Server"
%       3: Start Server
%       4: outputText = inferenceLMStudio('hello')

%   Copyright 2024 Ahmad Faisal Ayob, VSG Labs Sdn Bhd

    % Check if the user forgot to give the input variable
    if nargin < 1
        error('Input userString is required.');
    end


% Define the pattern to match the text to be replaced. The pattern captures the text between
% '{ ""role"": ""user"", ""content"": "' and '" }', ...
% Using non-greedy match (.*?) to ensure it stops at the first occurrence of '" }', ...
pattern = '""role"": ""user"", ""content"": ""(.*?)""';

% Define the curl command template as a string. Make sure to escape double quotes with another double quote
curlCommand_template = ['curl http://localhost:1234/v1/chat/completions ', ...
    '-H "Content-Type: application/json" ', ...
    '-d "{', ...
    '""messages"": [ ', ...
    '{ ""role"": ""system"", ""content"": ""You are an intelligent assistant. You always provide well-reasoned answers that are both correct and helpful."" },', ...
    '{ ""role"": ""user"", ""content"": ""Tell me about Batman. Which Batman movie is the best"" }', ...
    '],', ...
    '""temperature"": 0.7, ', ...
    '""max_tokens"": -1,', ...
    '""stream"": false', ...
    '}"'];


% Replace the matched text with the userString
% The $1 in the replacement text is a backreference to the captured group in the pattern,
% but since we want to replace the whole captured text, it's not used here.
% Instead, we directly use the new sentence for replacement.
curlCommand = regexprep(curlCommand_template, pattern, ['""role"": ""user"", ""content"": ""', userString, '"" ']);

% Display the updated curlCommand
% disp(curlCommand);

% Execute the curl command using the system function
[status, cmdout] = system(curlCommand);

% Check if the command was executed successfully
if status == 0
    % disp('Command executed successfully. Output:');  % uncomment this if you are interested in the status
    % disp(cmdout); % uncomment this if you are interested in the status
else
    disp('Command execution failed.');
end

% Set a pattern to pinpoint where the output text that we are interested in
% Regular expression to extract the sentence between "content": " and the closing "
pattern = '"content":\s*"((?:[^"\\]|\\.)*)"';

% Conduct regex to extract the output content
[startIdx, endIdx, tokenExtents] = regexp(cmdout, pattern, 'once');

% Extract the matched content
if ~isempty(tokenExtents)
    extractedContent = cmdout(tokenExtents(1,1):tokenExtents(1,2));

    % Replace \n with actual newline characters
    outputText = strrep(extractedContent, '\n', newline);
    
    % disp(outputText);
else
    disp('No match found.');
end

return





