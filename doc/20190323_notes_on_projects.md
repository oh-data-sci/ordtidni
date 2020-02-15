idea collection
===
# introduction
after the counting is done, what can we do with the results? here are some ideas. 

# ideas

## "thing explainer"
an automated text simplification alogrithm based on replacing rare words with more common ones. we would train it separately for nouns/verbs. first collect a set of common lemmas (say, top 5000th of the lemma frequency list for each category). we will try to find a common word replacement for each rare word, defined as a lemma of frequency of occurrance (middle 5000th - 50.000th words).

for each of the rarer words we will need all the sentences the word occurs in. then we need to classify these sentences by structure and identify the role the word plays (i.e. subject, object). next we find other sentences with similar structure and the most words in common with the original. if the word playing the same role as the rare word is a common word, return it. otherwise return the highest frequency word in the given role (even if original word).

we will maintain a list of the mappings from rare word to common one.


## compression metric
collect the text (and text only) of each source. measure the repetitiveness of each source by the compression percentage it gets. list sources by repetitiveness. 


##

