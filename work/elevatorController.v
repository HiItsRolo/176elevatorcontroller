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

always @(posedge clk)begin
   if (reset == 1) begin //if reset = 1, set to default
	elevatorstate <= 0;
	doorstate <= 0;
	count <= 0;
	nextstate <= 0;
	nextfloor <= 0;
   end

   else begin//if reset = 0
 case(floor)
    
   0: //ground floor
	if(elevatorstate == 0 && nextstate == 0)begin//elevator idle and nothing queued
	   if(doorstate == 0)begin //door close
		if(F1up == 1)begin //if F1 up button pressed
	  	   doorstate <= 1; //door open
	  	   nextstate <= 1;//elevator will queue a move up
		   count <= 0; //count should be reset if new up request
		   nextfloor <= 0;//F1up was requested but no floor button yet
	  	end
	  	else if(F2up == 1)begin
		   nextstate <= 1;
		   count <= 0;
		   nextfloor <= 1; //elevator was requested at floor 2
		   floor <= 1;
		   elevatorstate <= 1;
	  	end
		else if(F2down == 1)begin
		   nextstate <= 2;//elevator will move down once F2 is reached
		   count <= 0;
		   nextfloor <= 1;
		   floor <= 1;
		   elevatorstate <= 1;
		end
	  	else begin
		   if (F3up == 1)begin
		       nextstate <= 1;
		       count <= 0;
		       nextfloor <= 2;
		       floor <= 1;
		       elevatorstate <= 1;
		   end
		   else if (F3down == 1)begin
		       nextstate <= 2;
		       count <= 0;
		       nextfloor <= 2;
		       floor <= 1;
		       elevatorstate <= 1;
		   end
		   else if (F4down == 1)begin
		       nextstate <= 2;
		       count <= 0;
		       nextfloor <= 3;
		       floor <= 1;
		       elevatorstate <= 1;
		   end
		   else begin//if someone is inside but elevator is idle
		       if (Dopen == 1) begin //door open button pressed
		           doorstate <= 1;//door will open
		           count <= 0;
		       end
		       else if (F1 == 1) begin//current floor's request button pressed
		           doorstate <= 1;//door will open
		           count <= 0;
		       end
		       else begin
		           if (F2 == 1) begin//request floor 2 from inside elevator
			       nextstate <= 0;//elevator has to go up
			       count <= 0;
			       nextfloor <= 1;//will go to floor 2
			       floor <= 1;
			       elevatorstate <= 1;
			   end
		           else if (F3 == 1) begin
			       nextstate <= 0;
			       count <= 0;
			       nextfloor <= 2;
			       floor <= 1;
			       elevatorstate <= 1;
			   end
		           else if (F4 == 1) begin
			       nextstate <= 0;
			       count <= 0;
			       nextfloor <= 3;
			       floor <= 1;
			       elevatorstate <= 1;
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

	else if (elevatorstate == 0 && nextstate != 0)begin //elevatorstate idle and up queue
	   if(doorstate == 1)begin //if door is open
		if(count >= CT)begin//if count to 5
		   if(Dsensor == 1)
		      doorstate <= 1;//door should stay open if sensor is 1
		   else
		      doorstate <= 0;//door should close
		end
		else
		   count = count + 1;
	   end
	   else begin
		if(F1 == 1)begin
		   doorstate <= 1;
		   count <= 2;
		end
		else if(Dopen == 1)begin
		   doorstate <= 1;
		   count <= 2;
		end
		else if(F1up == 1) begin
		   doorstate <= 1;
		   count <= 2;
		end
		else if(F2 == 1)begin
		   nextfloor <= 1;
		   floor <= 1;
		   elevatorstate <= 1;
		end
		else if(F3 == 1)begin
		   nextfloor <= 2;
		   floor <= 1;
		   elevatorstate <= 1;
		end
		else if(F4 == 1)begin
		   nextfloor <= 3;
		   floor <= 1;
		   elevatorstate <= 1;
		end
		else 
		   nextstate <= 0;
	   end
	end

	else begin//if elevator has just arrived
	   if(elevatorstate == 2)begin
	   	nextfloor <= 0;
		elevatorstate <= 0;
		nextstate <= 1;
		count <= 0;
		doorstate <= 1;
	   end
	end
	
    1://check for signals when elevator is betweeen F1 and F2
	if(elevatorstate == 1)begin
	   if(nextfloor == 1)begin
	      if(F3 == 1 || F4 == 1)begin
		 nextstate <= 1;//queue a move up once at floor 2
		 floor <= 2;
	      end
	      else if(F3up == 1 || F4down == 1)begin
		 nextstate <= 1;
		 floor <= 2;
	      end
	      else if (F3down == 1 ||F2up == 1)begin
		 nextstate <= 1;
		 floor <= 2;
	      end
	      else if (F2down == 1 || F1up == 1)begin
		 nextstate <= 2;
		 floor <= 2;
	      end
	      else begin
		 nextstate <= 0;
		 floor <= 2;
	      end
	   end
	   else if(nextfloor == 2 || nextfloor == 3)begin
	      if(F2 == 1 || F2up == 1)begin
		 nextfloor <= 1;
		 nextstate <= 1;
		 floor <= 2;
	      end
	      else
		 floor <= 2;
	   end
	   else
		 floor <= 2;
	end
	else begin//if elevator is going down
	      nextstate <= 1;//queue a move up
	      floor <= 0;//go down to floor 0
	end

    2: //floor 2
	if(elevatorstate == 0 && nextstate == 0)begin//elevator idle and nothing queued
	   if(doorstate == 0)begin //door close
		if(F2up == 1)begin //if F2 up button pressed
	  	   doorstate <= 1; //door open
	  	   nextstate <= 1;//elevator will queue a move up
		   count <= 0; //count should be reset if new up request
		   nextfloor <= 1;//F2up was requested but no floor button yet
	  	end
	  	else if(F2down == 1)begin
		   doorstate <= 1;
		   nextstate <= 2;
		   count <= 0;
		   nextfloor <= 1;
	  	end
		else if(F3up == 1)begin
		   nextstate <= 1;//elevator will move up once F3 is reached
		   count <= 0;
		   nextfloor <= 2;
		   floor <= 3;
		   elevatorstate <= 1;
		end
	  	else begin
		   if (F3down == 1)begin
		       nextstate <= 2;
		       count <= 0;
		       nextfloor <= 2;
		       floor <= 3;
		       elevatorstate <= 1;
		   end
		   else if (F1up == 1)begin
		       nextstate <= 1;
		       count <= 0;
		       nextfloor <= 0;
		       floor <= 1;
		       elevatorstate <= 2;
		   end
		   else if (F4down == 1)begin
		       nextstate <= 2;
		       count <= 0;
		       nextfloor <= 3;
		       floor <= 3;
		       elevatorstate <= 1;
		   end
		   else begin//if someone is inside but elevator is idle
		       if (Dopen == 1) begin//if door open button pressed
		           doorstate <= 1;
		           count <= 0;
		       end
		       else if (F2 == 1) begin //if button for F2 is pressed while on fourth floor
		           doorstate <= 1;//door should open
		           count <= 0;
		       end
		       else begin
		           if (F3 == 1) begin //F3 requested from inside
			       nextstate <= 1;//up queued
			       count <= 0;
			       nextfloor <= 2;//next floor will be floor 3
			       floor <= 3;
			       elevatorstate <= 1;
			   end
		           else if (F1 == 1) begin
			       nextstate <= 2;
			       count <= 0;
			       nextfloor <= 0;//next floor will be floor 1
			       floor <= 1;
			       elevatorstate <= 2;
			   end
		           else if (F4 == 1) begin
			       nextstate <= 1;
			       count <= 0;
			       nextfloor <= 3;//next floor will be floor 3
			       floor <= 3;
			       elevatorstate <= 1;
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
		if(nextstate == 1)begin 
		   if(F2 == 1 || Dopen == 1)begin
		      doorstate <= 1;
		      count <= 2;
		   end
		   else if(F2up == 1)begin
		      doorstate <= 1;
		      count <= 2;	
		   end
		   else if(F3 == 1)begin
		      nextfloor <= 2;
		      floor <= 3;
		      elevatorstate <= 1;
		   end
		   else if(F4 == 1)begin
		      nextfloor <= 3;
		      floor <= 3;
		      elevatorstate <= 1;
		   end
		   else begin
		      nextstate <= 0;
		   end
		end
		else begin
		   if(F2 == 1 || Dopen == 1)begin
		      doorstate <= 1;
		      count <= 2;
		   end
		   else if(F2down == 1)begin
		      doorstate <= 1;
		      count <= 2;	
		   end
		   else if(F1 == 1)begin
		      nextfloor <= 0;
		      floor <= 1;
		      elevatorstate <= 2;
		   end
		   else begin
		      nextstate <= 0;
		   end
		end
	   end
	end

	else begin//elevatorstate != 0
	   if(elevatorstate == 1)begin//if elevator was going up
	      if(doorstate == 0)begin//if door closed
		 if(nextfloor == 1)begin
		    doorstate <= 1;
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
		       doorstate <= 1;//door should stay open if sensor is 1
		    else begin
		       if(nextstate == 1)begin
			  floor <= 3;
			  elevatorstate <= 1;
		     	  doorstate <= 0;//door should close
		       end
		       else if(nextstate == 2)begin
			  floor <= 1;
			  elevatorstate <= 2;
			  doorstate <= 0;
		       end
		       else begin
			  elevatorstate <= 0;
			  doorstate <= 0;
		       end
		    end
		 end
		 else
		    count = count + 1;//increases count if count isnt 5
	      end
	   end

	   else begin//elevator going down
	      if(doorstate == 0)begin//if door closed
		 if(nextfloor == 1)begin
		    doorstate <= 1;
		    count <= 0;
		 end
		 else if(nextfloor == 0)//if floor 3 or 4 requested
		    floor <= 1;
		 else
		    floor <= 3;
	      end
	      else begin//if door open
		 if(count >= CT)begin//count to 5
		    if(Dsensor == 1)
		       doorstate <= 1;//door should stay open if sensor is 1
		    else begin
		       if(nextstate == 2)begin
			  floor <= 1;
			  elevatorstate <= 2;
		     	  doorstate <= 0;//door should close
		       end
		       else if(nextstate == 1)begin
			  floor <= 3;
			  elevatorstate <= 1;
			  doorstate <= 0;
		       end
		       else begin
			  elevatorstate <= 0;
			  doorstate <= 0;
		       end
		    end
		 end
		 else
		    count = count + 1;//increases count if count isnt 5
	      end
	   end
	end
	

    4: if(count >= CT) //Floor 3
         begin
         count <= 0;
        end
        else
	 begin
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