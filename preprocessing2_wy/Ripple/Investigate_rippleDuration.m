durations_ripple = ripples.timestamps(:,2) - ripples.timestamps(:,1);
figure; histogram(durations_ripple);
max(durations_ripple)


figure; histogram(HSE.duration);
max(HSE.duration)


figure; histogram(ripple_HSE.duration);
max(ripple_HSE.duration)

durations_candidates = zeros( length(ripple_HSE_score_super),1);
for ee = 1: length(ripple_HSE_score_super)
    durations_candidates(ee) = ripple_HSE_score_super(ee).timestamps(2)- ripple_HSE_score_super(ee).timestamps(1);
end
figure; histogram(durations_candidates);
max(durations_candidates)