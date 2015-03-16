function robustpn_test()
% test robustpn_mex
% 
% Note that this test code requires ANN class:
% http://www.wisdom.weizmann.ac.il/~bagon/matlab.html#ann
%

imgs= [];    % Sowerby images
gts = [];   % ground truth
mss = [];   % mean-shift segmentation (see edison_wrapper)
% load Sowerby dataset
load('sowerby_imgs_gt.mat','imgs','gts','mss');

% build models according to training data
sti = randsample(numel(imgs), 10); % pick 10 training images at random
mdl = model({imgs{sti}}, {gts{sti}});
nl = numel(mdl);

% test the models
for ii=1:nl %1 sti'
    % foreach image
    sG = make_graph(imgs{ii});
    Dc = make_dc(imgs{ii}, mdl);
    hop = make_hop(mss{ii}, nl);

    % energy minimization
    [L E] = robustpn_mex(sG, Dc, hop);
    L = double(L+1);
    [uE pE hE mE] = energy(sG, Dc, hop, L);
    
    % display
    figure;
    subplot(2,2,1);
    imshow(imgs{ii}); title('input image');
    subplot(2,2,2);
    imagesc(gts{ii}); title('Grount-truth labeling');
    axis image;
    subplot(reshape(L,imsize(imgs{ii}))); title('Resulting labeling');
    axis image;
    colormap(rand(100,3));
    

    if (E~=mE)/E < 1e-5
        error('robustpn:test', 'wrong energy value');
    end
end

% close the model
for mi=1:numel(mdl),    mdl{mi} = close(mdl{mi}); end

%----------------------------------------%
% Aux functions
%----------------------------------------%
function [uE pE hE E] = energy(sG, Dc, hop, labels)
% given sG, Sc, hop and current labeling - return the energy

[nl nvar] = size(Dc);

% unary term
uE = sum(Dc( [1 nl]*( [labels(:)';1:nvar] -1) +1 ));

% pair-wise term - use only upper tri of sparseG
[rr cc]=find(sG);
low = rr>cc;
rr(low)=[];
cc(low)=[];
neq = labels(rr) ~= labels(cc);
pE = sum(single(full((sG( [1 size(sG,1)]*( [rr(neq(:))'; cc(neq(:))']-1 ) + 1 )))));


% HOpotentials energy
hE = 0;
for hi=1:numel(hop)

    P = sum(hop(hi).w);
    tk = (hop(hi).gamma(end) - hop(hi).gamma(1:end-1))./hop(hi).Q;
    fk = accumarray( [labels( hop(hi).ind(:) )' ; numel(tk)],...
        [hop(hi).w(:)' 0] )'; % make sure we have numrl(tk) elements
    hE = hE + min([(P-fk).*tk + hop(hi).gamma(1:end-1) hop(hi).gamma(end)]);

end

E = uE + pE + hE;

%----------------------------------------%
function     sG = make_graph(img)

[h w]=imsize(img);
sG = sparse(h*w,h*w);
lin = reshape(1:h*w, [h w]);

[dx dy] = gradient(im2double(img));
dx = max(dx.*dx, [], 3);
dy = max(dy.*dy, [], 3);
b = mean([dx(:);dy(:)]);

% 4 connect graph
% horizontal
sG( sub2ind([h*w h*w], lin(:,1:end-1), lin(:,2:end) ) ) = exp(-dx(:,1:end-1)./b);
sG( sub2ind([h*w h*w], lin(1:end-1,:), lin(2:end,:) ) ) = exp(-dy(1:end-1,:)./b);
sG = max(sG, sG'); % make it symmetric

%----------------------------------------%
function     Dc = make_dc(img, mdl)
[h w]=imsize(img);
Dc = 1000*ones([numel(mdl) h*w],'single');
fb = reshape( filter_bank(img), [h*w 10] )';

for mi=1:numel(mdl)
    if isempty(mdl{mi}), continue; end;
    [idx dst] = ksearch(mdl{mi}, fb, 80, .5);
    Dc(mi,:) = log(numel(mdl{mi})) - log( sum( exp(-dst*1000) ) );
end

%----------------------------------------%
function    hop = make_hop(mss,nl)
%  hop - higher order potential array of structs with (#higher) entries, each entry:
%      .ind - indices of nodes belonging to this hop
%      .w - weights w_i for each participating node
%      .gamma - #labels + 1 entries for gamma_1..gamma_max
%      .Q - truncation value for this potential (assumes one Q for all labels)
lrs=imresize(mss,2*imsize(mss),'bilinear');
nrs=imresize(mss,2*imsize(mss),'nearest');
d = bwdist(lrs~=nrs);
w = imresize(.5*d, imsize(mss), 'bilinear');
w = min(w+.1, 2); % weights - truncate them at 2 pixels, do not allow 0 weights
st = regionprops(mss+1,'PixelIdxList');
gamma(nl+1) = 10; % gamma_max
[hop(1:numel(st))] = deal(struct('ind',[],'w',[],...
    'gamma',single(gamma),'Q',.1));
for hi=1:numel(st)
    hop(hi).ind = st(hi).PixelIdxList;
    hop(hi).w = w(hop(hi).ind);
    P = sum(hop(hi).w);
    C = numel(st(hi).PixelIdxList);
    hop(hi).w = single(hop(hi).w .* C ./ P);
    hop(hi).Q = single(.1 * C);
    hop(hi).gamma(end) = single(C);
end


%----------------------------------------%

function mdl = model(imgs, gts)
% construct a model based on sample images + ground truth

fb = cell(8,1); % expecting 8 cluster types
for ii=1:numel(imgs)
    fr = filter_bank(imgs{ii});
    is = imsize(imgs{ii});
    fr = reshape(fr, [prod(is) size(fr,3)])';
    for ci=1:8
        fb{ci} = cat(2, fb{ci}, fr(:,gts{ii}(:)==ci));
    end
end

mdl = cell(1,8);
for ci=1:8
    try
        mdl{ci} = ann(fb{ci});
    catch % ME
        ME = lasterror;
        fprintf(1, 'Warn: ann error: %s\n', ME.identifier);
        fprintf(1, 'Make sure you have ANN class installed:\n');
        fprintf(1, '<a href="http://www.wisdom.weizmann.ac.il/~bagon/matlab.html#ann">');
        fprintf(1, 'http://www.wisdom.weizmann.ac.il/~bagon/matlab.html#ann</a>\n');
        mdl{ci} = [];
    end
end

%----------------------------------------%
function fb = filter_bank(img)
persistent fbk

if isempty(fbk)
    [x{1:2}] = meshgrid(-2:.5:2);
    r2 = x{1}.^2 + x{2}.^2;
    g = exp( -r2 ./ 2 )/(2*pi);
    fbk{1} = ( x{1}.*g );
    fbk{3} = ( x{2}.*g );
    fbk{2} = ( (cos(pi/4).*x{1}+sin(pi/4).*x{2}).*g );
    fbk{4} = ( (cos(pi/4).*x{1}-sin(pi/4).*x{2}).*g );
    fbk{5} = ( exp(-r2)/pi - g );
    clear x r2 g;
end

img = im2single(rgb2gray(img));

fb = zeros([imsize(img) 10],'single');
for fi=1:4
    fr = imfilter(img, fbk{fi},'symmetric');
    pr = single(fr > 0 );
    fb(:,:, fi) = pr.*fr;
    fb(:,:, fi+4) = (pr-1).*fr;
end
fb(:,:,9) = imfilter(img, fbk{5},'symmetric');

mag = sum(fb.^2,3);
fb(:,:,10) = mean(mag(mag(:)>0)).*single(mag<=.125*std(mag(:)));

%----------------------------------------%
function varargout = imsize(img)
iz = size(img);
iz = iz(1:2);
if nargout == 1
    varargout{1} = iz;
else
    varargout{1} = iz(1);
    varargout{2} = iz(2);
end
