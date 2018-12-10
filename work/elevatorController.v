module elevatorController
(
input clk, reset, Dsensor, //signals
Dopen, Dclose, //request door open/close
F1, F2, F3, F4,//buttons inside of elevator
F1up, F2down, F2up,//buttons outside of elevator f1 & f2
F3down, F3up, F4down,//buttons outside of elevator f3 & f4
output up, down,//outputs whether elevator is going up or down
output reg [2:0] floor//outputs what floor the elevator is currently on
);
reg[1:0] elevatorstate;//current state of elevator: idle, up, down
reg[1:0] doorstate;//current state of door: open, close
reg[4:0] count;//current count
reg[1:0] nextstate;//next state of elevator
reg[1:0] nextfloor;//next floor elevator will go to
parameter CT = 4'b0010;//parameter for counter
parameter OPEN = 1'b1, CLOSED = 1'b0; //parameters for door
parameter IDLE = 2'b00, UP = 2'b01, DOWN = 2'b10;

always @(posedge clk)begin
   if (reset == 1) begin //if reset = 1, set to default
	elevatorstate <= IDLE;
	doorstate <= CLOSED;
	count <= 0;
	nextstate <= IDLE;
	nextfloor <= 0;
   end

   else begin//if reset = 0
 case(floor)
    
   0: //ground floor
	if(elevatorstate == IDLE && nextstate == IDLE)begin//elevator idle and nothing queued
	   if(doorstate == CLOSED)begin //door close
		if(F1up == 1)begin //if F1 up button pressed
	  	   doorstate <= OPEN; //door open
	  	   nextstate <= UP;//elevator will queue a move up
		   count <= 0; //count should be reset if new up request
		   nextfloor <= 0;//F1up was requested but no floor button yet
	  	end
	  	else if(F2up == 1)begin
		   nextstate <= UP;
		   count <= 0;
		   nextfloor <= 1; //elevator was requested at floor 2
		   floor <= 1;
		   elevatorstate <= UP;
	  	end
		else if(F2down == 1)begin
		   nextstate <= DOWN;//elevator will move down once F2 is reached
		   count <= 0;
		   nextfloor <= 1;
		   floor <= 1;
		   elevatorstate <= UP;
		end
	  	else begin
		   if (F3up == 1)begin
		       nextstate <= UP;
		       count <= 0;
		       nextfloor <= 2;
		       floor <= 1;
		       elevatorstate <= UP;
		   end
		   else if (F3down == 1)begin
		       nextstate <= DOWN;
		       count <= 0;
		       nextfloor <= 2;
		       floor <= 1;
		       elevatorstate <= UP;
		   end
		   else if (F4down == 1)begin
		       nextstate <= DOWN;
		       count <= 0;
		       nextfloor <= 3;
		       floor <= 1;
		       elevatorstate <= UP;
		   end
		   else begin//if someone is inside but elevator is idle
		       if (Dopen == 1) begin //door open button pressed
		           doorstate <= OPEN;//door will open
		           count <= 0;
		       end
		       else if (F1 == 1) begin//current floor's request button pressed
		           doorstate <= OPEN;//door will open
		           count <= 0;
		       end
		       else begin
		           if (F2 == 1) begin//request floor 2 from inside elevator
			       nextstate <= IDLE;//elevator has to go up
			       count <= 0;
			       nextfloor <= 1;//will go to floor 2
			       floor <= 1;
			       elevatorstate <= UP;
			   end
		           else if (F3 == 1) begin
			       nextstate <= IDLE;
			       count <= 0;
			       nextfloor <= 2;
			       floor <= 1;
			       elevatorstate <= UP;
			   end
		           else if (F4 == 1) begin
			       nextstate <= IDLE;
			       count <= 0;
			       nextfloor <= 3;
			       floor <= 1;
			       elevatorstate <= UP;
			   end
			   else begin
			       doorstate <= CLOSED;
			       nextstate <= IDLE;
			       nextfloor <= floor;
			   end
		       end
		  end
	        end
	   end
	   else begin //if door open
		if(count >= CT)begin
		   if(Dsensor == 1)begin//if someone is in doorway
		      doorstate <= OPEN;//door stays open
		   end
		   else begin
		      doorstate <= CLOSED;//door close
	 	   end
		end 
		else begin
		    count <= count + 1;//up count if count isnt CT
		end
	   end
	end

	else if (elevatorstate == IDLE && nextstate != IDLE)begin //elevatorstate idle and up queue
	   if(doorstate == OPEN)begin //if door is open
		if(count >= CT)begin//if count to 5
		   if(Dsensor == 1)
		      doorstate <= OPEN;//door should stay open if sensor is 1
		   else
		      doorstate <= CLOSED;//door should close
		end
		else
		   count <= count + 1;
	   end
	   else begin
		if(F1 == 1)begin
		   doorstate <= OPEN;
		   count <= 2;
		end
		else if(Dopen == 1)begin
		   doorstate <= OPEN;
		   count <= 2;
		end
		else if(F1up == 1) begin
		   doorstate <= OPEN;
		   count <= 2;
		end
		else if(F2 == 1)begin
		   nextfloor <= 1;
		   floor <= 1;
		   elevatorstate <= UP;
		end
		else if(F3 == 1)begin
		   nextfloor <= 2;
		   floor <= 1;
		   elevatorstate <= UP;
		end
		else if(F4 == 1)begin
		   nextfloor <= 3;
		   floor <= 1;
		   elevatorstate <= UP;
		end
		else 
		   nextstate <= 0;
	   end
	end

	else begin//if elevator has just arrived
	   if(elevatorstate == DOWN)begin
	   	nextfloor <= 0;
		elevatorstate <= IDLE;
		nextstate <= IDLE;
		count <= 0;
		doorstate <= OPEN;
	   end
	end
	
    1://check for signals when elevator is betweeen F1 and F2
	if(elevatorstate == UP)begin//if elevator is moving up
	   if(nextfloor == 1)begin//if F2 is desired floor
	      if(F3 == 1 || F4 == 1)begin
		 nextstate <= UP;//queue a move up once at floor 2
		 floor <= 2;//go too floor 2
	      end
	      else if(F3up == 1 || F4down == 1)begin
		 nextstate <= UP;
		 floor <= 2;
	      end
	      else if (F3down == 1)begin
		 nextstate <= UP;
		 floor <= 2;
	      end
	      else if (F2up == 1)begin
	         nextstate <= IDLE;
		 floor <= 2;
	      end
	      else if (F2down == 1) begin
		 nextstate <= IDLE;
		 floor <= 2;
	      end
	      else if (F1up || F1 == 1)begin
		 nextstate <= DOWN;
		 floor <= 2;
	      end
	      else begin
		 nextstate <= IDLE;
		 floor <= 2;
	      end
	   end
	   else if(nextfloor == 2 || nextfloor == 3)begin
	      if(F2 == 1 || F2up == 1)begin
		 nextfloor <= 1;
		 nextstate <= UP;
		 floor <= 2;
	      end
	      else
		 floor <= 2;
		 nextstate <= UP;
	   end
	   else
		 floor <= 2;
	end
	else begin//if elevator is going down
	      nextstate <= UP;//queue a move up
	      floor <= 0;//go down to floor 0
	end

    2: //floor 2
	if(elevatorstate == IDLE && nextstate == IDLE)begin//elevator idle and nothing queued
	   if(doorstate == CLOSED)begin //door close
		if(F2up == 1)begin //if F2 up button pressed
	  	   doorstate <= OPEN; //door open
	  	   nextstate <= UP;//elevator will queue a move up
		   count <= 0; //count should be reset if new up request
		   nextfloor <= 1;//F2up was requested but no floor button yet
	  	end
	  	else if(F2down == 1)begin
		   doorstate <= OPEN;
		   nextstate <= DOWN;
		   count <= 0;
		   nextfloor <= 1;
	  	end
		else if(F3up == 1)begin
		   nextstate <= UP;//elevator will move up once F3 is reached
		   count <= 0;
		   nextfloor <= 2;
		   floor <= 3;
		   elevatorstate <= UP;
		end
	  	else begin
		   if (F3down == 1)begin
		       nextstate <= DOWN;
		       count <= 0;
		       nextfloor <= 2;
		       floor <= 3;
		       elevatorstate <= UP;
		   end
		   else if (F1up == 1)begin
		       nextstate <= UP;
		       count <= 0;
		       nextfloor <= 0;
		       floor <= 1;
		       elevatorstate <= DOWN;
		   end
		   else if (F4down == 1)begin
		       nextstate <= DOWN;
		       count <= 0;
		       nextfloor <= 3;
		       floor <= 3;
		       elevatorstate <= UP;
		   end
		   else begin//if someone is inside but elevator is idle
		       if (Dopen == 1) begin//if door open button pressed
		           doorstate <= OPEN;
		           count <= 0;
		       end
		       else if (F2 == 1) begin //if button for F2 is pressed while on fourth floor
		           doorstate <= OPEN;//door should open
		           count <= 0;
		       end
		       else begin
		           if (F3 == 1) begin //F3 requested from inside
			       nextstate <= UP;//up queued
			       count <= 0;
			       nextfloor <= 2;//next floor will be floor 3
			       floor <= 3;
			       elevatorstate <= UP;
			   end
		           else if (F1 == 1) begin
			       nextstate <= DOWN;
			       count <= 0;
			       nextfloor <= 0;//next floor will be floor 1
			       floor <= 1;
			       elevatorstate <= DOWN;
			   end
		           else if (F4 == 1) begin
			       nextstate <= UP;
			       count <= 0;
			       nextfloor <= 3;//next floor will be floor 3
			       floor <= 3;
			       elevatorstate <= UP;
			   end
			   else begin
			       doorstate <= CLOSED;
			       nextstate <= IDLE;
			       nextfloor <= floor;
			   end
		       end
		   end
	        end
	   end

	   else begin //if door open
		if(count >= CT)begin
		   if(Dsensor == 1)begin//if someone is in doorway
		      doorstate <= OPEN;//door stays open
		   end
		   else begin
		      doorstate <= CLOSED;//door close
	 	   end
		end 
		else begin
		    count <= count + 1;//up count if count isnt CT
		end
	   end
	end

	else if (elevatorstate == IDLE && nextstate != IDLE)begin //elevator idle and up/down queued
	   if(doorstate == OPEN)begin //if door is open
		if(count >= CT)begin//count to 5
		   if(Dsensor == 1)
		      doorstate <= OPEN;//door should stay open if sensor is 1
		   else
		      doorstate <= CLOSED;//door should close
		end
		else
		   count <= count + 1;//increases count if count isnt 5
	   end
	   else begin
		if(nextstate == UP)begin 
		   if(F2 == 1 || Dopen == 1)begin
		      doorstate <= OPEN;
		      count <= 2;
		   end
		   else if(F2up == 1)begin
		      doorstate <= OPEN;
		      count <= 2;	
		   end
		   else if(F3 == 1)begin
		      nextfloor <= 2;
		      floor <= 3;
		      elevatorstate <= UP;
		   end
		   else if(F4 == 1)begin
		      nextfloor <= 3;
		      floor <= 3;
		      elevatorstate <= UP;
		   end
		   else begin
		      nextstate <= IDLE;
		   end

		end
		else begin
		   if(F2 == 1 || Dopen == 1)begin
		      doorstate <= OPEN;
		      count <= 2;
		   end
		   else if(F2down == 1)begin
		      doorstate <= OPEN;
		      count <= 2;	
		   end
		   else if(F1 == 1)begin
		      nextfloor <= 0;
		      floor <= 1;
		      elevatorstate <= DOWN;
		   end
		   else begin
		      nextstate <= IDLE;
		   end
		end
	   end
	end

	else begin//elevatorstate != 0
	   if(elevatorstate == UP)begin//if elevator was going up
	      if(doorstate == CLOSED)begin//if door closed
		 if(nextfloor == 1)begin
		    doorstate <= OPEN;
		    count <= 0;
		 end
		 else if(nextfloor == 2 || nextfloor == 3)//if floor 3 or 4 requested
		    floor <= 3;
		 else
		    floor <= 1;
	      end
	      else begin//if door open
		 if(count >= CT)begin//count to 5
		    if(Dsensor == 1)
		       doorstate <= OPEN;//door should stay open if sensor is 1
		    else begin
		       if(nextstate == UP)begin
			  floor <= 3;
			  elevatorstate <= UP;
		     	  doorstate <= CLOSED;//door should close
		       end
		       else if(nextstate == DOWN)begin
			  floor <= 1;
			  elevatorstate <= DOWN;
			  doorstate <= CLOSED;
		       end
		       else begin
			  elevatorstate <= IDLE;
			  doorstate <= CLOSED;
		       end
		    end
		 end
		 else
		    count <= count + 1;//increases count if count isnt 5
	      end
	   end

	   else begin//elevator going down
	      if(doorstate == CLOSED)begin//if door closed
		 if(nextfloor == 1)begin
		    doorstate <= OPEN;
		    count <= 0;
		 end
		 else if(nextfloor == 0)//if floor 0 was requested
		    floor <= 1;//go down
		 else
		    floor <= 3;//next floor is 2 or 3, go up
	      end
	      else begin//if door open
		 if(count >= CT)begin//count to 5
		    if(Dsensor == 1)
		       doorstate <= OPEN;//door should stay open if sensor is 1
		    else begin
		       if(nextstate == DOWN)begin
			  floor <= 1;
			  elevatorstate <= DOWN;
		     	  doorstate <= CLOSED;//door should close
		       end
		       else if(nextstate == UP)begin
			  floor <= 3;
			  elevatorstate <= UP;
			  doorstate <= CLOSED;
		       end
		       else begin
			  elevatorstate <= IDLE;
			  doorstate <= CLOSED;
		       end
		    end
		 end
		 else
		    count = count + 1;//increases count if count isnt 5
	      end
	   end
	end
	
    3: //Control state between Floor 2 and Floor 3
	if(elevatorstate == UP)begin//if elevator is moving up
	   if(nextfloor == 2)begin//if F3 is desired floor
	      if(F4 == 1)begin//if F4 was also requested, keep moving up
		 nextstate <= UP;//queue a move up once at floor 3
		 floor <= 4;//go to floor 3
	      end
	      else if(F4down == 1)begin//if the elevator was requested at Floor 4
		 nextstate <= UP;//keep moving up even if desired floor was reached
		 floor <= 4;
	      end
	      else if (F3up == 1)begin
		 nextstate <= IDLE;
		 floor <= 4;
	      end
	      else if (F3down == 1 || F3 == 1)begin
	         nextstate <= IDLE;
		 floor <= 4;
	      end
	      else if (F2up == 1 || F2down == 1 || F2 == 1) begin
		 nextstate <= DOWN;
		 floor <= 4;
	      end
	      else if (F1up || F1 == 1)begin
		 nextstate <= DOWN;
		 floor <= 4;
	      end
	      else begin
		 nextstate <= IDLE;
		 floor <= 4;
	      end
	   end
	   else if(nextfloor == 3)begin
	      if(F3 == 1 || F3up == 1)begin
		 nextfloor <= 2;
		 nextstate <= UP;
		 floor <= 4;
	      end
	      else
		 floor <= 4;
		 nextstate <= UP;
	   end
	   else
		 floor <= 4;
	end
	else begin//if elevator is going down
	   if(nextfloor == 1)begin//if F2 is desired floor
	      if(F1 == 1||F1up == 1)begin
		 nextstate <= DOWN;//queue a move down once at floor 2
		 floor <= 2;//go too floor 2
	      end
	      else if(F2 == 1 || F2down == 1 || F2up == 1)begin
		 nextstate <= IDLE;
		 floor <= 2;
	      end
	      else if (F3up == 1 || F3 == 1 || F3down == 1)begin
		 nextstate <= UP;
		 floor <= 2;
	      end
	      else if (F4down == 1|| F4 == 1)begin
	         nextstate <= UP;
		 floor <= 2;
	      end
	      else begin
		 nextstate <= IDLE;
		 floor <= 2;
	      end
	   end
	   else if(nextfloor == 0)begin
	      if(F2 == 1 || F2up == 1)begin
		 nextfloor <= 1;
		 nextstate <= DOWN;
		 floor <= 2;
	      end
	      else
		 floor <= 2;
		 nextstate <= DOWN;
	   end
	   else//if Nextfloor == 2 or 3
		 floor <= 2;
	end


    4:
	if(elevatorstate == IDLE && nextstate == IDLE)begin//elevator idle and nothing queued
	   if(doorstate == CLOSED)begin //door close
		if(F2up == 1)begin //if F2 up button pressed
	  	   doorstate <= OPEN; //door open
	  	   nextstate <= UP;//elevator will queue a move up
		   count <= 0; //count should be reset if new up request
		   nextfloor <= 1;//F2up was requested but no floor button yet
	  	end
	  	else if(F2down == 1)begin
		   doorstate <= OPEN;
		   nextstate <= DOWN;
		   count <= 0;
		   nextfloor <= 1;
	  	end
		else if(F3up == 1)begin
		   nextstate <= UP;//elevator will move up once F3 is reached
		   count <= 0;
		   nextfloor <= 2;
		   floor <= 3;
		   elevatorstate <= UP;
		end
	  	else begin
		   if (F3down == 1)begin
		       nextstate <= DOWN;
		       count <= 0;
		       nextfloor <= 2;
		       floor <= 3;
		       elevatorstate <= UP;
		   end
		   else if (F1up == 1)begin
		       nextstate <= UP;
		       count <= 0;
		       nextfloor <= 0;
		       floor <= 1;
		       elevatorstate <= DOWN;
		   end
		   else if (F4down == 1)begin
		       nextstate <= DOWN;
		       count <= 0;
		       nextfloor <= 3;
		       floor <= 3;
		       elevatorstate <= UP;
		   end
		   else begin//if someone is inside but elevator is idle
		       if (Dopen == 1) begin//if door open button pressed
		           doorstate <= OPEN;
		           count <= 0;
		       end
		       else if (F2 == 1) begin //if button for F2 is pressed while on fourth floor
		           doorstate <= OPEN;//door should open
		           count <= 0;
		       end
		       else begin
		           if (F3 == 1) begin //F3 requested from inside
			       nextstate <= UP;//up queued
			       count <= 0;
			       nextfloor <= 2;//next floor will be floor 3
			       floor <= 3;
			       elevatorstate <= UP;
			   end
		           else if (F1 == 1) begin
			       nextstate <= DOWN;
			       count <= 0;
			       nextfloor <= 0;//next floor will be floor 1
			       floor <= 1;
			       elevatorstate <= DOWN;
			   end
		           else if (F4 == 1) begin
			       nextstate <= UP;
			       count <= 0;
			       nextfloor <= 3;//next floor will be floor 3
			       floor <= 3;
			       elevatorstate <= UP;
			   end
			   else begin
			       doorstate <= CLOSED;
			       nextstate <= IDLE;
			       nextfloor <= floor;
			   end
		       end
		   end
	        end
	   end

	   else begin //if door open
		if(count >= CT)begin
		   if(Dsensor == 1)begin//if someone is in doorway
		      doorstate <= OPEN;//door stays open
		   end
		   else begin
		      doorstate <= CLOSED;//door close
	 	   end
		end 
		else begin
		    count <= count + 1;//up count if count isnt CT
		end
	   end
	end

	else if (elevatorstate == IDLE && nextstate != IDLE)begin //elevator idle and up/down queued
	   if(doorstate == OPEN)begin //if door is open
		if(count >= CT)begin//count to 5
		   if(Dsensor == 1)
		      doorstate <= OPEN;//door should stay open if sensor is 1
		   else
		      doorstate <= CLOSED;//door should close
		end
		else
		   count <= count + 1;//increases count if count isnt 5
	   end
	   else begin
		if(nextstate == UP)begin 
		   if(F2 == 1 || Dopen == 1)begin
		      doorstate <= OPEN;
		      count <= 2;
		   end
		   else if(F2up == 1)begin
		      doorstate <= OPEN;
		      count <= 2;	
		   end
		   else if(F3 == 1)begin
		      nextfloor <= 2;
		      floor <= 3;
		      elevatorstate <= UP;
		   end
		   else if(F4 == 1)begin
		      nextfloor <= 3;
		      floor <= 3;
		      elevatorstate <= UP;
		   end
		   else begin
		      nextstate <= IDLE;
		   end

		end
		else begin
		   if(F2 == 1 || Dopen == 1)begin
		      doorstate <= OPEN;
		      count <= 2;
		   end
		   else if(F2down == 1)begin
		      doorstate <= OPEN;
		      count <= 2;	
		   end
		   else if(F1 == 1)begin
		      nextfloor <= 0;
		      floor <= 1;
		      elevatorstate <= DOWN;
		   end
		   else begin
		      nextstate <= IDLE;
		   end
		end
	   end
	end

	else begin//elevatorstate != 0
	   if(elevatorstate == UP)begin//if elevator was going up
	      if(doorstate == CLOSED)begin//if door closed
		 if(nextfloor == 1)begin
		    doorstate <= OPEN;
		    count <= 0;
		 end
		 else if(nextfloor == 2 || nextfloor == 3)//if floor 3 or 4 requested
		    floor <= 3;
		 else
		    floor <= 1;
	      end
	      else begin//if door open
		 if(count >= CT)begin//count to 5
		    if(Dsensor == 1)
		       doorstate <= OPEN;//door should stay open if sensor is 1
		    else begin
		       if(nextstate == UP)begin
			  floor <= 3;
			  elevatorstate <= UP;
		     	  doorstate <= CLOSED;//door should close
		       end
		       else if(nextstate == DOWN)begin
			  floor <= 1;
			  elevatorstate <= DOWN;
			  doorstate <= CLOSED;
		       end
		       else begin
			  elevatorstate <= IDLE;
			  doorstate <= CLOSED;
		       end
		    end
		 end
		 else
		    count <= count + 1;//increases count if count isnt 5
	      end
	   end

	   else begin//elevator going down
	      if(doorstate == CLOSED)begin//if door closed
		 if(nextfloor == 1)begin
		    doorstate <= OPEN;
		    count <= 0;
		 end
		 else if(nextfloor == 0)//if floor 0 was requested
		    floor <= 1;//go down
		 else
		    floor <= 3;//next floor is 2 or 3, go up
	      end
	      else begin//if door open
		 if(count >= CT)begin//count to 5
		    if(Dsensor == 1)
		       doorstate <= OPEN;//door should stay open if sensor is 1
		    else begin
		       if(nextstate == DOWN)begin
			  floor <= 1;
			  elevatorstate <= DOWN;
		     	  doorstate <= CLOSED;//door should close
		       end
		       else if(nextstate == UP)begin
			  floor <= 3;
			  elevatorstate <= UP;
			  doorstate <= CLOSED;
		       end
		       else begin
			  elevatorstate <= IDLE;
			  doorstate <= CLOSED;
		       end
		    end
		 end
		 else
		    count = count + 1;//increases count if count isnt 5
	      end
	   end
	end
	

    6:  if(elevatorstate == 0 && nextstate == 0)begin//elevator idle and nothing queued
	   if(doorstate == 0)begin //door close
		if(F4down == 1)begin //if F4 down button pressed
	  	   doorstate <= 1; //door open
	  	   nextstate <= 2;//elevator will queue a move down
		   count <= 0; //count should be reset if new down request
		   nextfloor <= 3;//F4down was requested but no floor button yet
	  	end
	  	else if(F3down == 1)begin
		   nextstate <= 2;
		   count <= 0;
		   nextfloor <= 2; //elevator was requested at floor 3
	  	end
		else if(F3up == 1)begin
		   nextstate <= 1;//elevator will move up once F3 is reached
		   count <= 0;
		   nextfloor <= 2;
		end
	  	else begin
		   if (F2down == 1)begin
		       nextstate <= 2;
		       count <= 0;
		       nextfloor <= 1;
		   end
		   else if (F2up == 1)begin
		       nextstate <= 1;
		       count <= 0;
		       nextfloor <= 1;
		   end
		   else if (F1up == 1)begin
		       nextstate <= 1;
		       count <= 0;
		       nextfloor <= 0;
		   end
		   else begin//if someone is inside but elevator is idle
		       if (Dopen == 1) begin//if door open button pressed
		           doorstate <= 1;
		           count <= 0;
		       end
		       else if (F4 == 1) begin //if button for F4 is pressed while on fourth floor
		           doorstate <= 1;//door should open
		           count <= 0;
		       end
		       else begin
		           if (F3 == 1) begin //F3 requested from inside
			       nextstate <= 2;//down queued
			       count <= 0;
			       nextfloor <= 2;//next floor will be floor 3
			   end
		           else if (F2 == 1) begin
			       nextstate <= 2;
			       count <= 0;
			       nextfloor <= 1;//next floor will be floor 2
			   end
		           else if (F1 == 1) begin
			       nextstate <= 2;
			       count <= 0;
			       nextfloor <= 0;//next floor will be floor 1
			   end
			   else begin
			       doorstate <= 0;
			       nextstate <= 0;
			       nextfloor <= floor;
			   end
		       end
		  end
	        end
	   end

	   else begin //if door open
		if(count >= CT)begin
		   if(Dsensor == 1)begin//if someone is in doorway
		      doorstate <= 1;//door stays open
		   end
		   else begin
		      doorstate <= 0;//door close
	 	   end
		end 
		else begin
		    count = count + 1;//up count if count isnt CT
		end
	   end
	end

	else if (elevatorstate == 0 && nextstate != 0)begin //elevator idle and up/down queued
	   if(doorstate == 1)begin //if door is open
		if(count >= CT)begin//count to 5
		   if(Dsensor == 1)
		      doorstate <= 1;//door should stay open if sensor is 1
		   else
		      doorstate <= 0;//door should close
		end
		else
		   count = count + 1;//increases count if count isnt 5
	   end
	   else begin
		elevatorstate <= 2;//elevator will move down
		floor <= 2;
	   end
	end
	else begin//elevatorstate == 2, elevator is moving down
	   if(elevatorstate == 1)begin
	   	nextfloor <= 3;
		elevatorstate <= 0;
		nextstate <= 0;
		count <= 0;
		doorstate <= 1;
	   end
	end

	default 
	begin 
	floor <= 0;
	elevatorstate <= 0;
	doorstate <= 0;
	count <= 0;
	nextstate <= 0;
	nextfloor <= 0;
	end

 endcase 
 end
end

endmodule 