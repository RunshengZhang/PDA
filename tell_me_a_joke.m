%   Tell Me a Joke
%   Yunyi
%   Nov 20

function here_is_the_joke = tell_me_a_joke()

joke{1} = 'A ham sandwich walks into a bar and orders a beer, \nbartender says "sorry, we don''t serve food here."';
joke{2} = 'What do you call an alligator detective? \nAn investi-gator.';
joke{3} = 'Why did the scarecrow win an award? \nBecause he was outstanding in his field.';
joke{4} = 'Why shouldn''t you write with a broken pencil? \nBecause it''s pointless';
joke{5} = 'A police officer jumps into his squad car and calls the station. \n“I have an interesting case here,” he says. \n“A woman shot her husband for stepping on the floor she just mopped.” \n“Have you arrested her?” asks the sergeant. \n“No, not yet. The floor''s still wet.”';
joke{6} = 'After finishing our Chinese food, my husband and I cracked open our fortune cookies. \nMine read, “Be quiet for a little while.” \nHis read, “Talk while you have a chance.”';
joke{7} = 'A couple are sitting in their living room, sipping wine. \nOut of the blue, the wife says, “I love you.” \n“Is that you or the wine talking?” asks the husband. \n“It’s me,” says the wife. “Talking to the wine.”';
joke{8} = 'Why couldn''t the leopard play hide and seek? \nBecause he was always spotted.';

index = randi(8);
here_is_the_joke = sprintf(joke{index});
