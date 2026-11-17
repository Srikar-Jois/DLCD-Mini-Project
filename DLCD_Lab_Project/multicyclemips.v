`timescale 1ns/1ps
module mips_multicycle(input wire clk, input wire reset);
    localparam FETCH=0, DECODE=1, MEM_ADDR=2, MEM_READ=3, MEM_WB=4,
               MEM_WRITE=5, EXEC_R=6, EXEC_I=7, ALU_WB=8, BRANCH=9;

    reg [3:0] state;
    reg [31:0] pc, ir, mdr, a, b, alu_out;
    reg [31:0] regs [0:31];
    reg [31:0] imem [0:63];
    reg [31:0] dmem [0:63];

    reg [31:0] cycle_count;
    reg [31:0] instr_count;

    wire [5:0] opcode = ir[31:26];
    wire [4:0] rs = ir[25:21];
    wire [4:0] rt = ir[20:16];
    wire [4:0] rd = ir[15:11];
    wire [5:0] funct = ir[5:0];
    wire [31:0] imm = {{16{ir[15]}}, ir[15:0]};

    integer i;

    initial begin
        for (i=0; i<64; i=i+1) begin
            imem[i] = 32'h00000000;
            dmem[i] = 32'h00000000;
        end

        imem[0]  = 32'h20080005; 
        imem[1]  = 32'h20090007; 
        imem[2]  = 32'h01095020; 
        imem[3]  = 32'h01285822; 
        imem[4]  = 32'hAC0A0000; 
        imem[5]  = 32'h8C0C0000; 
        imem[6]  = 32'h118A0001; 
        imem[7]  = 32'h200D0063;
        imem[8]  = 32'h01097024;
        imem[9]  = 32'h01097825; 
        imem[10] = 32'h0109802A; 
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= FETCH;
            pc <= 0;
            ir <= 0;
            mdr <= 0;
            a <= 0;
            b <= 0;
            alu_out <= 0;
            cycle_count <= 0;
            instr_count <= 0;
            for (i=0; i<32; i=i+1)
                regs[i] <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
            regs[0] <= 0;

            case (state)
                FETCH: begin
                    ir <= imem[pc[7:2]];
                    pc <= pc + 4;
                    state <= DECODE;
                end

                DECODE: begin
                    a <= (rs==0) ? 0 : regs[rs];
                    b <= (rt==0) ? 0 : regs[rt];
                    case (opcode)
                        6'b100011, 6'b101011: begin // lw, sw
                            alu_out <= ((rs==0) ? 0 : regs[rs]) + imm;
                            state <= MEM_ADDR;
                        end
                        6'b000100: begin // beq
                            alu_out <= pc + (imm << 2);
                            state <= BRANCH;
                        end
                        6'b000000: state <= EXEC_R;
                        6'b001000: state <= EXEC_I;
                        default: state <= FETCH;
                    endcase
                end

                MEM_ADDR: begin
                    state <= (opcode==6'b100011) ? MEM_READ : MEM_WRITE;
                end

                MEM_READ: begin
                    mdr <= dmem[alu_out[7:2]];
                    state <= MEM_WB;
                end

                MEM_WB: begin
                    if (rt != 0)
                        regs[rt] <= mdr;
                    instr_count <= instr_count + 1;
                    state <= FETCH;
                end

                MEM_WRITE: begin
                    dmem[alu_out[7:2]] <= b;
                    instr_count <= instr_count + 1;
                    state <= FETCH;
                end

                EXEC_R: begin
                    case (funct)
                        6'h20: alu_out <= a + b;       
                        6'h22: alu_out <= a - b;       
                        6'h24: alu_out <= a & b;       
                        6'h25: alu_out <= a | b;      
                        6'h2A: alu_out <= ($signed(a) < $signed(b)) ? 1 : 0; 
                        default: alu_out <= 0;
                    endcase
                    state <= ALU_WB;
                end

                EXEC_I: begin
                    alu_out <= a + imm;                
                    state <= ALU_WB;
                end

                ALU_WB: begin
                    if (opcode==6'b000000) begin
                        if (rd != 0)
                            regs[rd] <= alu_out;
                    end else begin
                        if (rt != 0)
                            regs[rt] <= alu_out;
                    end
                    instr_count <= instr_count + 1;
                    state <= FETCH;
                end

                BRANCH: begin
                    if (a == b)
                        pc <= alu_out;
                    instr_count <= instr_count + 1;
                    state <= FETCH;
                end

                default: state <= FETCH;
            endcase
        end
    end
endmodule
