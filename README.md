# Noodles
My attempt to recreate [Noodles!](https://apps.apple.com/us/app/noodles/id967624193) a very fun iPhone game made by [Michael Busheikin](https://twitter.com/lummoxlabs).

The goal is to rotate the tiles to create a single noodle that includes every tile and does not contain any loops. Left Click a tile to rotate it. Right Click to lock tiles you are sure are correct and Right Click them again to unlock them if you've made a mistake.

The "Rows:" and "Cols:" text boxes allow you to change the size of the next puzzle generated. The drop down menu lets you switch between square and haxagonal grids.

As a starting tip, look around the edges to find tiles that have limited options for which way to point.

![](https://i.imgur.com/D9UsnWL.png)
On very large grids, the process to check if you've won can be slow. It starts checking the noodle with the top left tile, so if you leave that one disconnected until the end, the game will run faster.