%{
on large grids it can be hard to spot where the web is broken
wincheck() is fairly slow on large grids
-can be sped up by "breaking" tile 1,1
- don't check when locking a tile

could use an actual indicator that you've won
%}
function [] = Noodles( )
	f = [];
	ax = [];
	grid = [];%matlab.graphics.primitive.Patch.empty;
	coords = [];
	color = [];
	rowT = [];
	colT = [];
	gameOver = [];
	hex = [];
	hexCheck = [];
	
	figureSetup();
	coordFill();
	newGame();	
	
	
	% this functions defines the coordinates used to draw all the tiles.
	% The hex tiles were originally drawn in Geometer's Sketchpad and then
	% transfered over
	function [] = coordFill()
		% adds coordinates needed to draw all the tiles.
		t = 1/3;
		t2 = 2/3;
		x = t+0.045;
		coords.Quad = -0.5 + [0 0 1 1; 0 1 1 0];
		coords.End = -0.5+[t t 1.5*t-0.5*x 1.5*t-0.5*x 1.5*t+0.5*x 1.5*t+0.5*x t2 t2; 1 1-x 1-x 1-2*x 1-2*x 1-x 1-x 1];
		coords.Line = -0.5+[t t t2 t2; 1 0 0 1];
		coords.Corner = -0.5+[t t 1 1 t2 t2; 0 t2 t2 t t 0];
		coords.Tri = -0.5+[t t t2 t2 1 1 t2 t2; 0 1 1 t2 t2 t t 0];
		coords.Plus = -0.5+[t t 0 0 t t t2 t2 1 1 t2 t2; 0 t t t2 t2 1 1 t2 t2 t t 0];
		
		L = 1/6;
		L1 = 1-L;
		L2 = L1-L;
		k = cosd(30);
		c = k/9; %cy
		j = c*2; %jy
		n = k/3; %ny
		m = k*2/3; %my
		
		% the number indicates how many connections it has. the letter
		% indicates which variation
		coords.hex = 0. + m*[ -0.5 -1 -0.5 0.5 1 0.5; k 0 -k -k 0 k];
		coords.h1 = 0. + m*[ -L -L 0 L L; k -c -j -c k];
		
		coords.h2a = 0. + m*[ -L -L 0 L1 L2 L L; k -c -j n m n k];
		coords.h2b = 0. + m*[ -L -L L2 1-L L L; k -c -m -n c k];
		coords.h2c = 0. + m*[ -L -L L L; k -k -k k];
		
		coords.h3a = 0. + m*[ -L -L L2 L1 t L1 L2 L L; k -c -m -n 0 n m n k];
		coords.h3b = 0. + m*[ -L -L L L L1 L2 L L; k -k -k -c n m n k];
		coords.h3c = 0. + m*[ -L -L L L L2 L1 L L; k -k -k -n -m -n c k];
		coords.h3d = 0. + m*[ -L -L -L1 -L2 0 L2 L1 L L; k c -n -m -j -m -n c k];
		
		coords.h4a = 0. + m*[ -L -L L L L2 L1 t L1 L2 L L; k -k -k -n -m -n 0 n m n k];
		coords.h4b = 0. + m*[ -L -L -L2 -L1 -L -L L L L1 L2 L L; k n m n -c -k -k -c n m n k];
		coords.h4c = 0. + m*[ -L -L -L2 -L1 -L -L L L L2 L1 L L; k n m n -c -k -k -n -m -n c k];
		
		coords.h5 = 0. + m*[ -L -L -L2 -L1 -t -L1 -L2 0 L2 L1 t L1 L2 L L; k n m n 0 -n -m -j -m -n 0 n m n k];
		
		coords.h6 = 0. + m*[ -L -L -L2 -L1 -t -L1 -L2 -L -L L L L2 L1 t L1 L2 L L; k n m n 0 -n -m -n -k -k -n -m -n 0 n m n k];	
		
	end
	
	% checks to see if the noodle has been fully connected
	function [win] = wincheck()
		board = ones(size(grid)); % board keeps track of which tiles have not been checked yet
		recCheck(1,1);
		if nnz(board)~=0 % checks if the noodle actually uses every tile
			win = false;
		else
			win = true;
		end
		
		% recursive check. gets called for each connection of the tile
		% being checked. 
		function [w] = recCheck(r,c)
			board(r,c) = 0;
			w = true;
			d = grid(r,c).UserData.Dirs;
			for t = d % check in the direction of each connection
				dc = round(cosd(t));
				dr = round(sind(t));
				if hex
					if t==30 || t==150
						dr = mod(c,2)==1;
					elseif t==210 || t==330
						dr = mod(c,2) - 1;
					end
				end
				if r+dr<=size(board,1) && r+dr>=1 && c+dc<=size(board,2) && c+dc>=1 && any(grid(r+dr,c+dc).UserData.Dirs==mod(t+180,360))% checks if the adjacent tile is connected
					if board(r+dr,c+dc) % checks that the noodle hasn't created a loop. would cause the recursion to be in a loop too
						w = recCheck(r+dr,c+dc);
						if ~w
							return
						end
					end
				else
					w = false;
					return
				end
			end
		end
	end
	
	% creates the figure and other intitial graphics objects
	function [] = figureSetup()
		f = figure(1);
		clf('reset');
		f.MenuBar = 'none';
		
		
		ax = axes('Parent',f);
		ax.Position = [0.025 0.025 0.95 0.9];
		ax.XTick = [];
		ax.YTick = [];
		ax.YDir = 'reverse';
		ax.XColor = [1 1 1];
		ax.YColor = [1 1 1];
		axis equal
		
		f.WindowButtonUpFcn = @click;
		
		ng = uicontrol(...
			'Parent',f,...
			'Style','pushbutton',...
			'Units','normalized',...
			'String','New Game',...
			'FontUnits','normalized',...
			'FontSize',0.625,...
			'Position',[0.78 0.9275 0.2 0.07],...
			'Callback',@newGame);
		
		rowLbl = uicontrol(...
			'Parent',f,...
			'Style','text',...
			'Units','normalized',...
			'String','Rows:',...
			'FontUnits','normalized',...
			'FontSize',0.625,...
			'HorizontalAlignment','right',...
			'Position',[0.025 0.9275 0.1 0.07]);
		rowT = uicontrol(...
			'Parent',f,...
			'Style','edit',...
			'Units','normalized',...
			'String','5',...
			'FontUnits','normalized',...
			'FontSize',0.625,...
			'Position',[0.125 0.9275 0.05 0.07]);
		
		colLbl = uicontrol(...
			'Parent',f,...
			'Style','text',...
			'Units','normalized',...
			'String','Cols:',...
			'FontUnits','normalized',...
			'FontSize',0.625,...
			'HorizontalAlignment','right',...
			'Position',[0.2 0.9275 0.1 0.07]);
		colT = uicontrol(...
			'Parent',f,...
			'Style','edit',...
			'Units','normalized',...
			'String','5',...
			'FontUnits','normalized',...
			'FontSize',0.625,...
			'Position',[0.3 0.9275 0.05 0.07]);
		
		hexCheck = uicontrol(...
			'Parent',f,...
			'Style','popupmenu',...
			'Units','normalized',...
			'String',{'Quad','Hex'},...
			'FontUnits','normalized',...
			'FontSize',0.625,...
			'Position',[0.6 0.9275 0.15 0.07]);
		

	end
	
	% starts a new game
	function [] =  newGame(~,~)
		% generates a random color with a constraint on the brightness
		color = rand(1,3);
		while norm(color)<1
			color = rand(1,3);
		end
		
		cla
				
		hex = hexCheck.Value - 1;
		r = str2num(rowT.String);
		c = str2num(colT.String);
		
		gameOver = false;
		
		if hex
			x = [sind(60)-0.51/sind(60) sind(60)*c+1*0.5/sind(60)];
			y = [0.5 r+1];
			axis([x, y])
			hexPreview(r,c)
			hexGen(r,c);
		else
			axis(0.5*[1 -1 1 -1]+[0 c+1, 0 r+1])
			quadPreview(r,c)
			gridGen(r,c);
		end
	end
	
	% handles mouse clicks. triggered on the release of the click
	function [] = click(~,~)
		if gameOver
			return
		end
		if hex
			m = ax.CurrentPoint([1,3]); %x,y = c,r
			m(1) = round((m(1))/sind(60));
			m(2) = round(m(2)-0.5*mod(m(1),2));
		else
			m = round(ax.CurrentPoint([1,3]));
		end
		if any(m<1) || m(1)>size(grid,2) || m(2)>size(grid,1) % check that it's actually clicking on a tile
			return
		end
		
		switch f.SelectionType
			case {'normal', 'open'} % rotate on left click or double click
				if ~grid(m(2),m(1)).UserData.lock
					rotate(grid(m(2),m(1)));
				end
				gameOver = wincheck();
			case 'alt' % (un)lock on right click
				grid(m(2),m(1)).UserData.lock = ~grid(m(2),m(1)).UserData.lock;
				if grid(m(2),m(1)).UserData.lock
					grid(m(2),m(1)).EdgeColor = 1-0.375*color;
					grid(m(2),m(1)).LineWidth = 4;
				else
					grid(m(2),m(1)).EdgeColor = [0 0 0];
					grid(m(2),m(1)).LineWidth = 0.5;
				end
		end
	end
	
	% generates the grid for the hexagon variant
	function [] = hexGen(nr,nc)
		grid = gobjects(nr,nc);
		% Dirs - 0 is pos x (right on screen), 90 is pos y (down on screen)
		lines = zeros(nr*2-1,nc*2-1);
		badlines = lines;
		for i = 1:size(lines,1) % make empty lines, i=row, j=col
			for j = 1:size(lines,2)
				if ~(mod(i,2) && mod(j,2))
					lines(i,j) = 1;
				end
			end
		end
		
		l = find(lines & ~badlines); % remove lines randomly
		while ~isempty(l)
			i = randi(length(l));
			lines(l(i)) = 0;
			if ~stillAChain(lines, nr*nc, hex)
				lines(l(i)) = 1;
				badlines(l(i)) = 1; % stores lines that break the chain. can't remove them
			end
			l = find(lines & ~badlines);
		end
		
		% fill in the pieces
		for r = 1:nr
			for c = 1:nc
				% figure out which directions each tile has in the solution
				Dirs = [];
				if c~=nc && lines(r*2-1,c*2)==1 % line to the right
					if mod(c,2)==0
						Dirs = 30;
					else
						Dirs = 330;
					end
				end
				if c~=1 && lines(r*2-1,c*2-2)==1 % line to the left
					if mod(c,2)==1
						Dirs = [Dirs, 210];
					else
						Dirs = [Dirs, 150];
					end
				end
				if r~=1 && lines(r*2-2,c*2-1)==1 % line above
					Dirs = [Dirs, 270];
				end
				if r~=nr && lines(r*2,c*2-1)==1 % line below
					Dirs = [Dirs, 90];
				end
				if r~=nr && c~=nc && mod(c,2)==1 && lines(r*2,c*2)==1 % line down and right
					Dirs = [Dirs, 30];
				end
				if r~=1 && c~=1 && mod(c,2)==0 && lines(r*2-2,c*2-2)==1 % line up and left
					Dirs = [Dirs, 210];
				end
				if r~=nr && c~=1 && mod(c,2)==1 && lines(r*2,c*2-2)==1 % line down and left
					Dirs = [Dirs, 150];
				end
				if r~=1 && c~=nc && mod(c,2)==0 && lines(r*2-2,c*2)==1 % line up and right
					Dirs = [Dirs, 330];
				end
				
				% use those directions to determine what tile to draw. also
				% gets the dirs needed to match the tile when first drawn
				Dirs = sort(Dirs);
				switch length(Dirs)
					case 1
						p = coords.h1;
						d2 = 90;
					case 2
						switch diff(Dirs)
							case {60, 300}
								p = coords.h2a;
								d2 = [30, 90];
							case {120, 240}
								p = coords.h2b;
								d2 = [90, 330];
							case 180
								p = coords.h2c;
								d2 = [90, 270];
						end
					case 3
						d = diff(Dirs);
						if all(d==60) || any(d==240)
							p = coords.h3a;
							d2 = [30, 90, 330];
						elseif all(d==120)
							p = coords.h3d;
							d2 = [90, 210, 330];
						else
							d = diff(Dirs);
							if all(d == [180, 60]) || all(d==[120,180]) || all(d==[60,120])
								% 90, 270, 330 variant
								p = coords.h3c;
								d2 = [90, 270, 330];
							else
								p = coords.h3b;
								d2 = [30, 90, 270];
							end
						end
					case 4
						d = diff(Dirs);
						if any(d==180) || all(d==60)
							p = coords.h4a;
							d2 = [30, 90, 270, 330];
						elseif all(d==[60, 120, 60]) || all(d==[120,60,120])
							p = coords.h4c;
							d2 = [90, 150, 270, 330];
						else
							p = coords.h4b;
							d2 = [30, 90, 150, 270];
						end
					case 5
						p = coords.h5;
						d2 = [30, 90, 150, 210, 330];
					case 6
						p = coords.h6;
						d2 = 30+60*(0:5);
				end
				r2 = r + 0.5*mod(c,2); % accounts for the staggering
				c2 = c*sind(60);

				grid(r,c) = patch(c2+p(1,:), r2+p(2,:),color);
				grid(r,c).UserData.r = r2;
				grid(r,c).UserData.c = c2;
				grid(r,c).UserData.lock = false;
				grid(r,c).UserData.Dirs = d2;
				for i=1:randi(6)-1
					rotate(grid(r,c)); % spin the tile a few times, so they don't all start pointing the same direction
				end
			end
		end
	end
	
	% generates the grid for the quad variant
	function [] = gridGen(nr,nc)
		grid = gobjects(nr,nc);
		% Dirs - 0 is pos x (right on screen), 90 is pos y (down on screen)
		lines = zeros(nr*2-1,nc*2-1);
		badlines = lines;
		for i = 1:size(lines,1) % make empty lines
			for j = 1:size(lines,2)
				if mod(i,2) ~= mod(j,2)
					lines(i,j) = 1;
				end
			end
		end
		
		l = find(lines & ~badlines); % remove lines randomly
		while ~isempty(l)
			i = randi(length(l));
			lines(l(i)) = 0;
			if ~stillAChain(lines, nr*nc, hex) % check that it didn't break the noodle
				lines(l(i)) = 1;
				badlines(l(i)) = 1;
			end
			l = find(lines & ~badlines);
		end
		
		for r = 1:nr % fill in the pieces
			for c = 1:nc
				Dirs = [];
				if c~=nc && lines(r*2-1,c*2)==1
					Dirs = 0;
				end
				if r~=1 && lines(r*2-2,c*2-1)==1
					Dirs = [Dirs, 90];
				end
				if c~=1 && lines(r*2-1,c*2-2)==1
					Dirs = [Dirs, 180];
				end
				if r~=nr && lines(r*2,c*2-1)==1
					Dirs = [Dirs, 270];
				end
				
				switch length(Dirs)
					case 1
						grid(r,c) = patch(c+coords.End(1,:),r+coords.End(2,:),color);
						grid(r,c).UserData.Dirs = 90;
					case 2
						if diff(Dirs)==180
							grid(r,c) = patch(c+coords.Line(1,:),r+coords.Line(2,:),color);
							grid(r,c).UserData.Dirs = [90, 270];
						else
							grid(r,c) = patch(c+coords.Corner(1,:),r+coords.Corner(2,:),color);
							grid(r,c).UserData.Dirs = [0 270];
						end
					case 3
						grid(r,c) = patch(c+coords.Tri(1,:),r+coords.Tri(2,:),color);
						grid(r,c).UserData.Dirs = [0 90 270];
					case 4
						grid(r,c) = patch(c+coords.Plus(1,:),r+coords.Plus(2,:),color);
						grid(r,c).UserData.Dirs = 90*(0:4);
				end
				grid(r,c).UserData.r = r;
				grid(r,c).UserData.c = c;
				grid(r,c).UserData.lock = false;
				for i=1:randi(4)-1
					rotate(grid(r,c));
				end
			end
		end
	end
	
	% rotates tiles. graphics and stored data is updated
	function [] = rotate(obj)
		t = 90 - hex*30;
		
		r = obj.UserData.r;
		c = obj.UserData.c;

		y = obj.YData - r;
		x = obj.XData - c;

		obj.XData = c + x*cosd(t) - y*sind(t);
		obj.YData = r + y*cosd(t) + x*sind(t);

		obj.UserData.Dirs = sort(mod(obj.UserData.Dirs+t,360));
	end

	% draws the background hexagons
	function [] = hexPreview(r,c)
		patch(ax.XLim(2)*[0 0 1 1], [ax.YLim fliplr(ax.YLim)],0.1875*color)
		for qwe = 1:c
			for asd = 1:r
				patch(qwe*sind(60) + coords.hex(1,:), 0.5*mod(qwe,2) + asd + coords.hex(2,:),0.375*color)
			end
		end
	end
	
	% draws the background squares
	function [] = quadPreview(r,c)
		for qwe = 1:c
			for asd = 1:r
				patch(qwe + coords.Quad(1,:), asd + coords.Quad(2,:),0.375*color)
			end
		end
	end
end

% checks if the noodle being generated is still a single noodle.
function [itIs] = stillAChain(linegrid, total, hex)
	board = zeros(size(linegrid));
	recChain(1,1)
	itIs = (total == sum(sum(board)));
	
	% the recursion part
	function [] = recChain(r,c)
		board(r,c) = 1;
		
		if hex
			if r < size(linegrid,1)-1 && c < (size(linegrid,2)-1) && mod(c,4)==1 && board(r+2,c+2)~=1 && linegrid(r+1,c+1)==1 % down,right
				recChain(r+2,c+2)
			end
			if r > 2 && c < (size(linegrid,2)-1) && mod(c,4)==3 && board(r-2,c+2)~=1 && linegrid(r-1,c+1)==1 % up,right
				recChain(r-2,c+2)
			end
			if r < size(linegrid,1)-1 && c > 2 && mod(c,4)==1 && board(r+2,c-2)~=1 && linegrid(r+1,c-1)==1 % down,left
				recChain(r+2,c-2)
			end
			if r > 2 && c > 2 && mod(c,4)==3 && board(r-2,c-2)~=1 && linegrid(r-1,c-1)==1 % up, left
				recChain(r-2,c-2)
			end
		end
		if c < (size(linegrid,2)-1) && board(r,c+2)~=1 && linegrid(r,c+1)==1 % line to the right
			recChain(r,c+2)
		end
		if c > 2 && board(r,c-2)~=1 && linegrid(r,c-1)==1 % line to the left
			recChain(r,c-2)
		end
		if r < size(linegrid,1)-1 && board(r+2,c)~=1 && linegrid(r+1,c)==1 % line to the down
			recChain(r+2,c)
		end
		if r > 2 && board(r-2,c)~=1 && linegrid(r-1,c)==1 % line to the up
			recChain(r-2,c)
		end
	end
end