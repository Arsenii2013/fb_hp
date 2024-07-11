`ifndef __B2F_SV__
`define __B2F_SV__

module b2f_m
#( 
    parameter DDS_FREQ = 150_000_000
)
(
    input  logic        clk,     //! тактовый сигнал
    input  logic        rst,     //! сброс в значение по умолчанию
    
    input  logic        start,   //! запуск подсчета
    output logic        ready,   //! сигнал готовности значения частоты

    input  logic [31:0] field,   //! значение магнитного поля: максимальное значение 128 T, квант ~29.8 нТ
    input  logic [31:0] a,       //! a - коэффициент формулы
    input  logic [31:0] b,       //! b - коэффициент формулы
    input  logic [31:0] c,       //! c - коэффициент формулы
    input  logic [31:0] k,       //! Номер рабочей гармоники ВЧ
   
    output logic [31:0] freq     //! результат подсчета частоты: Freq[Hz]*(2^32)/(F_clk)
);

//------------------------------------------------
`timescale 1ns/1ps

//------------------------------------------------
//
//      Types
//
typedef logic [ 31:0] data32_t;
typedef logic [ 63:0] data64_t;
typedef logic [127:0] data128_t;

typedef struct {
    logic     start;
    logic     ready;
    data64_t  n;
    data64_t  d;
    data64_t  q;
    data64_t  r;
} div_signals_t;

typedef struct {
    logic     start;
    logic     ready;
    data64_t  a;
    data64_t  b;
    data128_t p;
} mult_signals_t;

typedef struct {
    logic     start;
    logic     ready;
    data64_t  r;
    data32_t  q;
} sqrt_signals_t;

typedef enum {
    IDLE,
    STAGE1,
    STAGE2,
    STAGE3,
    STAGE4,
    WAIT_RES
} state_t;

//------------------------------------------------
//
//      Objects
//
logic [31:0] field_r;
logic [31:0] a_r;
logic [31:0] b_r;
logic [31:0] c_r;
logic [31:0] k_r;

state_t state = IDLE;

div_signals_t  div;
mult_signals_t mult[2];
sqrt_signals_t sqrt;

//------------------------------------------------
//
//      Logic
//
assign ready = state == IDLE;

always_ff @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
    end
    else begin
        case (state)
            IDLE: begin
                state   <= start ? STAGE1 : IDLE;
                field_r <= field;
                a_r     <= a;
                b_r     <= b;
                c_r     <= c;
                k_r     <= k;
            end
            STAGE1: begin
                mult[0].start <= 1;
                mult[0].a     <= data64_t'(field_r);
                mult[0].b     <= data64_t'(field_r);
                div.start     <= 1;
                div.n         <= data64_t'(a_r) << 16;
                div.d         <= data64_t'(DDS_FREQ);
                state         <= STAGE2;
            end
            STAGE2: begin
                mult[0].start <= 0;
                div.start     <= 0;
                if (!mult[0].start && mult[0].ready && !div.start && div.ready) begin
                    mult[0].start <= 1;
                    mult[0].a     <= data64_t'(field_r);
                    mult[0].b     <= data64_t'(div.q);
                    mult[1].start <= 1;
                    mult[1].a     <= data64_t'(c_r);
                    mult[1].b     <= data64_t'(mult[0].p);
                    state         <= STAGE3;
                end
            end
            STAGE3: begin
                mult[0].start <= 0;
                mult[1].start <= 0;
                if (!mult[0].start && mult[0].ready && !mult[1].start && mult[1].ready) begin
                    mult[0].start <= 1;
                    mult[0].a     <= data64_t'(k_r);
                    mult[0].b     <= data64_t'(mult[0].p);
                    sqrt.start    <= 1;
                    sqrt.r        <= (data64_t'(b_r) << 18) + data64_t'(mult[1].p >> 32);
                    state         <= STAGE4;
                end
            end
            STAGE4: begin
                sqrt.start    <= 0;
                mult[0].start <= 0;
                if (!mult[0].start && mult[0].ready && !sqrt.start & sqrt.ready) begin
                    div.start <= 1;
                    div.n     <= data64_t'(mult[0].p);
                    div.d     <= data64_t'(sqrt.q);
                    state     <= WAIT_RES;
                end
            end
            WAIT_RES: begin
                div.start <= 0;
                if (!div.start & div.ready) begin
                    freq  <= data32_t'(div.q);
                    state <= IDLE;
                end        
            end
        endcase
    end
end

//------------------------------------------------
//
//      Instances
//
sqrt_m #( .DW ( 64 ) ) sqrt_inst
(
    .clk       ( clk           ),
    .rst       ( rst           ),
    .start     ( sqrt.start    ),
    .ready     ( sqrt.ready    ),
    .r         ( sqrt.r        ),
    .q         ( sqrt.q        )
);
//------------------------------------------------
div_m #(  .DW (  64 ) ) div_inst
(
    .clk       ( clk           ),
    .rst       ( rst           ),
    .start     ( div.start     ),
    .ready     ( div.ready     ),
    .n         ( div.n         ),
    .d         ( div.d         ),
    .q         ( div.q         ),
    .r         (               )
);
//------------------------------------------------
mult64x64_m mult0_inst
(
    .clk       ( clk           ),
    .rst       ( rst           ),
    .start     ( mult[0].start ),
    .ready     ( mult[0].ready ),
    .a         ( mult[0].a     ),
    .b         ( mult[0].b     ),
    .p         ( mult[0].p     )
);
//------------------------------------------------
mult64x64_m mult1_inst
(
    .clk       ( clk           ),
    .rst       ( rst           ),
    .start     ( mult[1].start ),
    .ready     ( mult[1].ready ),
    .a         ( mult[1].a     ),
    .b         ( mult[1].b     ),
    .p         ( mult[1].p     )
);
//------------------------------------------------
endmodule : b2f_m


///***_______testbench_______***///

//! параметры для задания магнитного поля
`define B_QUANT (128/(4294967295))
`define B_START_T 0.02
`define B_STEP_T  0.01
`define B_STOP_T  10.0
`define B_START_Q 671088    //~20mT (`B_START_T/`B_QUANT)
`define B_STEP_Q 335544     //~10mT (`B_STEP_T/`B_QUANT)
`define B_STOP_Q 335544320  //~10T (`B_START_T/`B_QUANT)
//! коэффициенты пересчета для Бустера NICA
`define A (937546000)  
`define B (867339)
`define C (436224)
`define K (66)

module b2f_tb();

//testbench defines
//
integer i=0;

reg[31:0] b_field;              //! значение магнитного поля: максимальное значение 128 T, квант ~29.8 нТ
reg[31:0] a_coeff;              //! a - коэффициент формулы
reg[31:0] b_coeff;              //! b - коэффициент формулы
reg[31:0] c_coeff;              //! c - коэффициент формулы
reg[31:0] k_coeff;              //! Номер рабочей гармоники ВЧ
reg reset;                      //! сброс в значение по умолчанию
reg clk;                        //! тактовый сигнал
reg start;                      //! запуск подсчета
//
reg[31:0] freq;                 //! реузьлтат подсчета частоты: Freq[Hz]*(2^32)/(F_clk)
reg ready;                      //! 

b2f_m #( .DDS_FREQ( 100_000_000 ) ) b2f(
    .field(b_field),            //! значение магнитного поля: максимальное значение 128 T, квант ~29.8 нТ
    .a(a_coeff),                //! a - коэффициент формулы
    .b(b_coeff),                //! b - коэффициент формулы
    .c(c_coeff),                //! c - коэффициент формулы
    .k(k_coeff),                //! Номер рабочей гармоники ВЧ
    .rst(reset),                //! сброс в значение по умолчанию
    .clk(clk),                  //! тактовый сигнал
    .start(start),              //! запуск подсчета
    //
    .freq(freq),                //! реузьлтат подсчета частоты: Freq[Hz]*(2^32)/(F_clk)
    .ready(ready)               //! сигнал готовностси значения частоты
);



// имитация сигналов
initial begin
    b_field = `B_START_Q;
    a_coeff = `A;
    b_coeff = `B;
    c_coeff = `C;
    k_coeff = `K;
    start   = 0;
    reset   = 0;
    clk     = 0;
    
    #5 reset <= 1;
    #5 reset <= 0;
end

// тактовая частота
always begin
    clk = ~clk; 
    #5;
end

// подстановка значений магнитного поля
always begin
    #50;
    for(i=0; i<1000; i=i+1) begin
        start = 1'h1;
        #10;
        start = 1'h0;
        #2500;
        b_field = b_field + `B_STEP_Q;
        if (b_field > `B_STOP_Q) begin
            b_field = `B_START_Q;
        end
    end
end

endmodule

`endif//__B2F_SV__