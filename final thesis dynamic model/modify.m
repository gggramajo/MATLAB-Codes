aerotab = {'cyb' 'cnb' 'clq' 'cmq'};

aero1{1}.cLq=aero1{1}.(aerotab{3})(1,1,1);
for k = 1:length(aerotab)
    if k==3
        for m = 1:aero1{1}.nmach
            for h = 1:aero1{1}.nalt
                aero1{1}.(aerotab{k})(:,m,h) = 0;
            end
        end
    else
        for m = 1:aero1{1}.nmach
            for h = 1:aero1{1}.nalt
                aero1{1}.(aerotab{k})(:,m,h) = aero1{1}.(aerotab{k})(1,m,h);
            end
        end
    end
end