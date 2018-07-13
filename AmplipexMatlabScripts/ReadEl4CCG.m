% function [spiket, spiekind, numclus, spikeph, ClustByEl] = ReadEl4CCGLoc(fname,ellist)
% reads spike timings of set of cells 'neurons' from fname.res and fname.clu
% writes a result as a cell array 
function [spiket, spikeind, numclus, iEleClu, spikeph] = ReadEl4CCG(fname,ellist)

if nargin<2 | isempty(ellist)
    par=LoadPar([fname '.par']);
    ellist=[1:par.nElecGps];
end

elnum=length(ellist);
resdata=cell(elnum,1);
cludata=cell(elnum,1);
clunum=zeros(elnum,1);

for i=1:elnum
    k=ellist(i);
    resfile = sprintf('%s.res.',fname);
    clufile = sprintf('%s.clu.',fname);
    resdata{i} = load(strcat(resfile,num2str(k)));
    cludatatmp = load(strcat(clufile,num2str(k)));
    cludata{i} = cludatatmp(2:end);
    clunum(i) = max(cludata{i});    
%     if nargout>3 & FileExists([fname '.spkph.' num2str(k)])
% 	spkphdata{i}=load([fname '.spkph.' num2str(k)]);
%     end
end
%eltimedata = cell(elnum,max(clunum));
spiket=[];
spikeind=[];
spikeph=[];
cnt=1;

%%ClustByEl =[];
iEleClu = [];
for i=1:elnum
%    loc = load([fname '.uloc']);
	for j=2:clunum(i)
      whichclu=find(eq(cludata{i},j));
      numspk=length(whichclu);
      eltimedata  = resdata{i}(whichclu);
      spiket=[spiket; eltimedata];
      spikeind=[spikeind;ones(numspk,1)*cnt];
%       if nargout>3 & FileExists([fname '.spkph.' num2str(k)])
%       	spikeph = [spikeph; spkphdata{i}(whichclu)];
% 		end
%%       ClustByEl(end+1) = ellist(i);
		iEleClu = [iEleClu; cnt i j];
      cnt=cnt+1;
    end
end

numclus=cnt-1;
[spiket sortind] =sort(spiket);
spikeind = spikeind(sortind);
