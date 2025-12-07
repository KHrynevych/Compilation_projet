RAPPORT PROJET:
Auteurs:
Raphaël Dubach
Kyrylo Hrynevych

Difficultés:
Return de plusieurs variables:
Puisque la première option proposée dans le sujet avait l'air très compliquée à implémenter, nous avons plutôt opté pour la deuxième.
Elle était en vérité également très difficile, puisqu'il fallait également traiter le cas où l'on déclarait plusieurs variables à partir d'une fonction rendant plusieurs variables,
et les instructions à implémenter étaient, à notre avis, vraiment pas évidentes...

Finir dans les temps:
Nous étions occupés pendant presque tout le mois où nous devions faire le projet; couplé à la longueur du projet et à la durée assez courte pour le faire,
cela nous a donné beaucoup de mal à terminer à temps.


Détails importants (parties du projet pouvant présenter des dysfonctionnements):
print:
Nous avons eu l'idée d'associer une opération, un bool ou un int à une impression de int. Cela fait que 

tests:
nous manquons probablement de tests, mais ceux que nous avons ajoutés vérifient:
- que l'analyseur syntaxique et le typechecker renvoient bien une erreur s'il y en a une, dans les cas les plus courants
- que toutes les instructions soient bien reconnus par l'analyseur syntaxique
- Que les programmes en MIPS renvoient la bonne valeur, en utilisant un compilateur de MIPS à coté