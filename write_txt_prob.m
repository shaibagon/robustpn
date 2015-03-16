function write_txt_prob(filename, Dc, sG, hop)
% write a text file with definition of potentials


fid = fopen(filename, 'w');

% data cost
fprintf(fid, 'Dc %d %d\n', size(Dc,1), size(Dc,2));
fprintf(fid, '%f ', Dc(:));

% sG
[rr cc] = find(sG);
fprintf(fid, '\nSc %d\n', numel(rr));
for ii=1:numel(rr)
    fprintf(fid, '%d %d %f\n', rr(ii), cc(ii), sG(rr(ii),cc(ii)));
end

% HOP
fprintf(fid, 'hop %d\n', numel(hop));
for ii=1:numel(hop)
    fprintf(fid, '%d %d\n', ii, numel(hop(ii).ind));
    fprintf(fid, '%d ', hop(ii).ind);
    fprintf(fid, '\n');
    fprintf(fid, '%f ', hop(ii).w);
    fprintf(fid, '\n');
    fprintf(fid, '%f ', hop(ii).gamma);
    fprintf(fid, '\n%f\n', hop(ii).Q);
end
fclose(fid);