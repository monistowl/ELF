Physio=ELF.Physio('mindware_physio.mw');
Events=ELF.Events('mindware_events.txt');
Windows=Events.winsBetween({'Neutral','Power','Threat'},'End');
Windows=Physio.hrvWinStats(Windows,'WinVars',{'RSA','SDNN'});
Windows.wins_t