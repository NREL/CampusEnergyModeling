function [result] = writeConfigFile(inTable, outTable, dirPath) 
% WRITECONFIGFILE - This function creates/replaces the variables.cfg file
% according to the inputs given.
%
% Usage: [result] = writeConfigFile(inTable, outTable, dirPath)
% Inputs: 
% inTable - Contains a Cell Array with Inputs to EnergyPlus.
% outTable - Contains a Cell Array with Outputs from EnergyPlus.
% dirPath - Contains a string with the path to the directory where to 
% write the variables.cfg file. This should be the same as the .IDF path. 
%
% Outputs:
% result - Contains information whether it succeeded or failed. 
%
% (C) 2013 by Willy Bernal (willyg@seas.upenn.edu)

% HISTORY:
%   2013-08-05 Started.
%

% Create Document Type
docType = com.mathworks.xml.XMLUtils.createDocumentType('SYSTEM', [],'variables.dtd');

% Create Document
docNode = com.mathworks.xml.XMLUtils.createDocument([], 'BCVTB-variables', docType);
docNode.setEncoding('ISO-8859-1');
docNode.setVersion('1.0')

% Input Comment 
docRootNode = docNode.getDocumentElement;
%docRootNode.setAttribute('SYSTEM','variables.dtd');
docRootNode.appendChild(docNode.createComment('INPUT'));

% Add Inputs
for i=1:size(inTable,1)
    thisElement = docNode.createElement('variable'); 
    thisElement.setAttribute('source','Ptolemy');
    newElement = docNode.createElement('EnergyPlus');
    newElement.setAttribute(inTable(i,3),inTable(i,4));
    thisElement.appendChild(newElement);
    docRootNode.appendChild(thisElement);
end

% Output Comment
docRootNode.appendChild(docNode.createComment('OUTPUT'));

% Add Outputs
for i=1:size(outTable,1)
    thisElement = docNode.createElement('variable'); 
    thisElement.setAttribute('source','EnergyPlus');
    newElement = docNode.createElement('EnergyPlus');
    newElement.setAttribute('name',outTable(i,3));
    newElement.setAttribute('type',outTable(i,4));
    thisElement.appendChild(newElement);
    docRootNode.appendChild(thisElement);
end

% Write variables.cfg and print the information
xmlFileName = [filesep 'variables.cfg'];
xmlFileNamePath = [dirPath xmlFileName];
xmlwrite(xmlFileNamePath,docNode);
type(xmlFileNamePath);
disp(['variables.cfg has been written in ' xmlFileNamePath]);
result = 1;
end