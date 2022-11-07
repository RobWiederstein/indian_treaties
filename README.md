![treaty](/img/1866-04-28_choctaw_chicasaw_treaty.png)

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [indian_treaties](#indian_treaties)   
- [00. Background](#00-background)   
   - [Scope](#scope)   
   - [Dataset](#dataset)   
- [01. Word Frequencies](#01-word-frequencies)   
   - [Does word frequency differ between rejected and valid treaties?](#does-word-frequency-differ-between-rejected-and-valid-treaties)   
- [02. Sentiment Analysis](#02-sentiment-analysis)   
   - [What was the overall sentiment of a treaty?](#what-was-the-overall-sentiment-of-a-treaty)   
- [03. tf-idf](#03-tf-idf)   
   - [What words have the highest tf-idf by class?](#what-words-have-the-highest-tf-idf-by-class)   
- [04. N-grams](#04-n-grams)   
   - [What bigrams have the highest tf-idf by class?](#what-bigrams-have-the-highest-tf-idf-by-class)   
- [05. LDA Implementation](#05-lda-implementation)   
   - [What words did the LDA algorithm discover?](#what-words-did-the-lda-algorithm-discover)   
- [06. Machine Learning with `glmnet`](#06-machine-learning-with-glmnet)   
   - [What coefficients were identified with a treaty's passage?](#what-coefficients-were-identified-with-a-treatys-passage)   
- [Resources](#resources)   
- [Citation](#citation)   

<!-- /MDTOC -->
# indian_treaties

# 00. Background

This project is a textual analysis of the treaties between the United States and Indigenous People of North America during the years 1784 - 1911. The project relies on the `tidytext` package and its dependencies and follows the book "[Text Mining with R](https://www.tidytextmining.com/tfidf.html)" by Julia Silge and David Robinson.

## Scope

This textual analysis is an effort to understand how the language used in treaties correlates with its ultimate legal disposition.  The textual analysis is not intended to minimize, explain, or address the treatment of Indigenous People during the period examined. Journal articles, web pages and treaties use different descriptors over time when referring to Indigenous People of North America including Indians, Indigenous People, and specific names of tribal nations. The author will refer to the Indigenous People of North America by reference to a specific tribal nation when that information is known, the actual language used in a treaty being discussed, or "Indigenous People." The analysis attempts to use the most inclusive and culturally respectful term.

## Dataset

The dataset encompasses 595 treaties between the United States and Indigenous Peoples and was first published in digital form by Professor Arthur Spirling. His article, cited below, "US treaty making with American Indians: Institutional change and relative power, 1784–1911" analyzed the dataset.  Of particular interest to Spirling was how treaty approval was impacted when Congress overtook the treaty power from the President in 1871.

He grouped the treaties by their legal disposition.  The four groups are (1) valid and operable (VCUT), (2) ratified (ACUT), (3) rejected (RCUT), and unratified (UCUT).  In the analysis, the variable was named `class`.  For context, Spirling described the treaty corpus as follows:

> “All told, we have 595 documents of interest—all scanned or rewritten as plain text files (UTF-8)—which may be broken down into several legal categories. First, there are those which are Valid and Operable (365 texts): beginning after the Revolution with the Treaty of Fort Stanwix of 1784 signed with the six nations, and ending with a treaty signed with the Nez Perce in 1868, these treaties have been ratified under Article II. Second, Ratified Agreements (77): these documents originate in 1871 after the purported “end” of treaty making and were ratified in statute form. Third, Rejected by Congress (85): this class of documents exemplifies the “broken” treaties in the sense that this term is used to refer to deals that were particularly cavalier regarding Indian rights (Deloria and DeMallie 1999, 745) and is the sum total of those that were submitted to the Senate, but not ratified. Finally, Unratified Treaties (68): this class of documents includes all the treaties signed before 1868 (and thus potentially includable in the first category above) yet never submitted for Senate ratification in the usual way.”

(Would two categories be more appropriate?  Unratified and rejected treaties have the same legal effect in that they are not binding upon the United States.  Also, valid and ratified agreements are have the same effect in that they bind the US to future action. Does this impact the analysis?)

(Double check the word "shall". It looks like the "l"s may be encoded as "1"s and becoming either "sha 1" or "sha11". The inclusion of many "shall"s within an agreement may make it less likely to pass. The analysis dropped numbers, so it could be impactful.)

# 01. Word Frequencies

One measure of a word's importance is the number of times it appears within a text. This is measured by its term frequency (tf). The treaties were processed using the process described in Text Mining with R. Words were converted to lowercase, punctuation omitted, "stop words" excluded, any word that began with or was a number was omitted, the word "article" was dropped,  and so too were words that were two or fewer characters in length. (There were a lot of lower case roman numerals omitted ("vi") that probably were numbers for the articles.) Each word was counted, grouped by the treaty's legal classification, and then divided by the total number of words for a term frequency.  

## Does word frequency differ between rejected and valid treaties?

Plot 1 is created following the methodology described in [Text Mining with R-Chapter 1](https://www.tidytextmining.com/tidytext.html).

![Treaty Word Frequency](/plots/valid_vs_rejected.png "US-Indian Treaty Word Frequency")

Words that are close to the dashed, diagonal line in these plots appear with similar frequency in both sets of texts.  For example, the word "united" is at the upper-frequency end and it appears in equal proportions in all of the datasets.  This makes sense as "united" is likely one of the parties to the treaties as in the "United States." Words that are far from the line are words that are found more in one set of documents than another. For example, in the "Valid" panel, words like "confederated“ and "clark" are found in valid and operable (VCUT) agreements, but not as much in "Rejected" (RCUT) documents. Additional plots are available for the [ratified](/plots/valid_vs_ratified.png) and [unratified](/plots/valid_vs_unratified.png).

# 02. Sentiment Analysis

The sentiment analysis relies on a sentiment lexicon where words have been paired with their positive or negative connotation. For example, "abandon" is considered to be a negative word and receives a -2 score, according to the AFINN lexicon/dictionary.  One reluctance in applying a sentiment lexicon to the treaties is that the dictionary is modern while the treaties are historic. Silge and Robinson addressed this concern in the context of historic fiction.  They state:

>we may hesitate to apply these sentiment lexicons to styles of text dramatically different from what they were validated on, such as narrative fiction from 200 years ago. While it is true that using these sentiment lexicons with, for example, Jane Austen’s novels may give us less accurate results than with tweets sent by a contemporary writer, we still can measure the sentiment content for words that are shared across the lexicon and the text.

## What was the overall sentiment of a treaty?

![sentiment analysis](/plots/treaty_sentiment_score.png)

The sentiment was computed by class and treaties using the "Bing" lexicon. The treaty with the lowest sentiment score of -28 was `U0015.txt`. The treaty was entered at "Spring Creek near the River San Saba, in the Indian country of the State of Texas" on December 10, 1850, between the United States and various Indian chiefs. Representatives of the "Comanches", "Tawacanoes", and "Wacoes" tribe signed the agreement. The implementation of the agreement was to be monitored by the Commanding Officer of Fort Martin Scott. (The treaty makes for some interesting reading and this
Wikipedia [article](https://en.wikipedia.org/wiki/Comanche_history#Raiding_Mexico:_1779-1870) discusses Comanche and Texas history.)

The treaty with the highest sentiment score of +110 was `V0351.txt` This treaty's signatories were the "Choctaw and Chickasaw Nations of Indians" and, of course, the United States in Washington D.C. on April 28, 1866. The Choctaw and Chickasaw agreed that neither slavery nor involuntary servitude would be permitted within their lands. Persons of African descent were guaranteed "all the rights, privileges, and immunities, including the right of suffrage". Former slaves were also to receive forty acres on the same terms as the Choctaws and Chickasaws after the Indians selected their plots. However, former slaves were not to receive any money as a result of the treaty. There are a total of 51 separate articles. A nicely formatted [version](https://treaties.okstate.edu/treaties/treaty-with-the-choctaw-and-chickasaw-1866.-(0918)) is furnished courtesy of Oklahoma State University.


# 03. tf-idf


"tf-idf" is short for term frequency–inverse document frequency. A second  approach in textual analysis is to look at a term’s inverse document frequency (idf). The *idf* is a measure that decreases the weight of commonly used words and increases the weight of infrequently used words within a document. When used upon works of literature, the characters' proper names are revealed with the tf-idf analysis. Using a "tf-idf" approach on the treaties reveals more unique words with many tribes' names present.

## What words have the highest tf-idf by class?

![Treaty tf-idf](/plots/treaties_tf_idf.png)

# 04. N-grams

Instead of words, the text will be parsed into bi-grams. According to [Wikipedia](https://en.wikipedia.org/wiki/Bigram), a bigram is "a sequence of two adjacent elements from a string of tokens, which are typical letters, syllables, or words. A bigram is an n-gram for n=2." Bigrams allow the study of "relationships between words, whether examining which words tend to follow others immediately, or that tend to co-occur within the same documents."

## What bigrams have the highest tf-idf by class?

![A plot](/plots/treaties_bigram_tf_idf.png)

# 05. LDA Implementation

"Latent Dirichlet allocation (LDA) is a particularly popular method for fitting a topic model. It treats each document as a mixture of topics, and each topic as a mixture of words."

## What words did the LDA algorithm discover?

![lda_plot](/plots/treaty_lda_plot.png)

# 06. Machine Learning with `glmnet`

WARNING: This plot was generated from a glmnet model that at the time of publication was performing worse than random chance.  It is likely to change or be discarded entirely!

## What coefficients were identified with a treaty's passage?

![glmnet](/plots/ml_glmnet_coef_prob.jpg)

# Resources

- [National Archives - American Indian Treaties](https://www.archives.gov/research/native-americans/treaties)

- [Rights of Native Americans](http://recordsofrights.org/themes/4/rights-of-native-americans)

# Citation

- Sigle, J., Hvitfeldt, E. (2021). [Supervised Machine Learning for Text Analysis in R](https://smltar.com). United Kingdom: CRC Press.

- Silge J, Robinson D (2016). “tidytext: Text Mining and Analysis Using Tidy
Data Principles in R.” _JOSS_, *1*(3). doi: 10.21105/joss.00037 (URL:
https://doi.org/10.21105/joss.00037), <URL:
http://dx.doi.org/10.21105/joss.00037>.

- Spirling, Arthur. "US treaty making with American Indians: Institutional change and relative power, 1784–1911." American Journal of Political Science 56.1 (2012): 84-97.
