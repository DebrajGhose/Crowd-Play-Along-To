%Generate notation that a crowd can play along to

clear all
close all

%set up video writing stuff

video = VideoWriter('Test.avi');
open(video);

figure1 = figure('Position', [0 , 0 , 2300 , 1400 ]);

%Set up simulation parameters

length = 200; %size of your domain
drawfreq = 30; %frequency with which it draws stuff till a new note can appear
lowerby = 20/drawfreq; %amount by which you want the notes to be lowered
shapesize = 1000;
disappear_height = 180; %height at which the shape should disappear
noteshape = '<o>s^dvhhp'; %shapes of your notes
notecolor = { [0.1 0.1 0.7] [0.1 0.7 0.2] [0.7 0.2 0.7] [0.7 0.3 0.1] [0.6 0.7 0.2] ...
    [0.5 0.2 0.9] [0.9 0.3 0.7] [0.4 0.9 0.7] [0.2 0.9 0.2] [0.3 0.4 0.9]  }; %colors of your notes
colornow = {[] [] [] [] [] [] [] [] [] [] }; %this holds the current color the note is going to be
lightentolerance = 10; %proximity for when lightening kicks in


%define arrays to hold your notes; these just hold the x and y locations of your notes

notes = { [] [] [] [] [] [] [] [] [] [] }; %first 8 cells hold notes in an octave. Final two cells hold bass and snare

%load input array

input = [ 1 0 1 0 0 0 1 1 0 1; 1 0 0 0 0 0 1 1 1 0 ; 0 1 0 0 0 0 1 1 0 1; 1 1 1 1 1 1 1 1 1 1];

% loop to generate your video

sizeofinput = numel(input(:,1)); %number of things (notes) that are going to be fed

for i = 1:(sizeofinput + round(length/lowerby)) %the simulation will run for as long as it takes the last note to reach the bottom of the screen
    
    if i <= sizeofinput %there will be an error if this condition is not there
        
        for m=1:numel(notes)
            
            if input(i,m) == 1 %check if a note exists at this location 
                notes{m} = [notes{m} ; [m,length] ]; 
                colornow{m} = [colornow{m} ; notecolor{m} ];
            end
            
        end
        
    end
    
    for loweri = 1:drawfreq %lower notes in the domain y
        
        for m=1:numel(notes)
            if ~isempty(notes{m})
                notes{m} = notes{m} - [0,lowerby];
            end
        end
        
        %make notes that reach the end disappear
        
        
        for m=1:numel(notes)
            
            if ~isempty(notes{m})
                if notes{m}(1,2) <= disappear_height
                    
                    notes{m}(1,:) = [];
                    colornow{m}(1,:) = [];
                    
                end
            end
            
        end
        
        %'lighten' effect for when note disappears
        
        for m=1:numel(notes)
            if ~isempty(notes{m})
                error = notes{m}(1,2) - disappear_height;
                
                if error < lightentolerance
                    
                   colornow{m}(1,:) = colornow{m}(1,:) + ( 1 - colornow{m}(1,:)    )*1/(1 + (0.5*error)^4) ;
                    
                end
            end
        end
        
        %plot things
        hold off
        
        %plot line
        
        plot( 0:11 , disappear_height*ones(1,12) ,'r' , 'LineWidth',2 );
        
        
        hold on
        
        %plot all your notes
        
        for m=1:numel(notes)
            
            if ~isempty(notes{m})
                scatter( notes{m}(:,1) , notes{m}(:,2) , shapesize ,'fill' , noteshape(m) , 'cdata' , colornow{m} );
            end
            
        end
        
        
        %plot properties
        
        axis([ 0 , 11 , 0 , length    ]) ;
        
        %axis off
        set(gca,'Color','k' , 'YTick', [] , 'XTick',[] )
        drawnow
        
        %write into video file
        writeVideo(video, getframe(figure1) );
        
    end
end

close(video);