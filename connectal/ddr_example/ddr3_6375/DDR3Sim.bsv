import FIFO::*;
import Vector::*;
import RegFile::*;
import Connectable::*;
import GetPut::*;
import DDR3Controller::*;
import DDR3Common::*;
import SpecialFIFOs::*;

typedef Bit#(29) DDR3Address;
typedef Bit#(64) ByteEn;
typedef Bit#(512) DDR3Data;

module mkDDR3Simulator(DDR3_User_VC707_1GB);
   RegFile#(Bit#(26), DDR3Data) data <- mkRegFileFull();
   FIFO#(DDR3Data) response <- mkFIFO();
   
   Clock user_clock <- exposeCurrentClock;
   Reset user_reset_n <- exposeCurrentReset;
   
   // Rotate 512 bit word by offset 64 bit words.
   function Bit#(512) rotate(Bit#(3) offset, Bit#(512) x);
      Vector#(8, Bit#(64)) words = unpack(x);
      Vector#(8, Bit#(64)) rotated = rotateBy(words, unpack((~offset) + 1));
      return pack(rotated);
   endfunction
   
       // Unrotate 512 bit word by offset 64 bit words.
   function Bit#(512) unrotate(Bit#(3) offset, Bit#(512) x);
      Vector#(8, Bit#(64)) words = unpack(x);
      Vector#(8, Bit#(64)) unrotated = rotateBy(words, unpack(offset));
      return pack(unrotated);
   endfunction
   
   interface clock = user_clock;
   interface reset_n = user_reset_n;
   method Bool init_done() = True;
   
   method Action request(DDR3Address addr, ByteEn writeen, DDR3Data datain);
      Bit#(26) burstaddr = addr[28:3];
      Bit#(3) offset = addr[2:0];
      
      Bit#(512) mask = 0;
      for (Integer i = 0; i < 64; i = i+1) begin
         if (writeen[i] == 'b1) begin
            mask[(i*8+7):i*8] = 8'hFF;
         end
      end
      
      Bit#(512) old_rotated = rotate(offset, data.sub(burstaddr));
      //Bit#(512) old_rotated = rotate(offset, data[burstaddr]);
      Bit#(512) new_masked = mask & datain;
      Bit#(512) old_masked = (~mask) & old_rotated;
      Bit#(512) new_rotated = new_masked | old_masked;
      Bit#(512) new_unrotated = unrotate(offset, new_rotated);
      data.upd(burstaddr, new_unrotated);
      //data[burstaddr] <=  new_unrotated;
      
      if (writeen == 0) begin
         response.enq(new_rotated);
      end
   endmethod
      
   method ActionValue#(DDR3Data) read_data;
      let v <- toGet(response).get();
      return v;
   endmethod
      
endmodule
