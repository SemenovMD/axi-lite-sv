module axil_arbiter_priority_wr
#(
    parameter   NUMBER_MASTER   =   2
)

(
    input   logic                                   aclk,
    input   logic                                   aresetn,

    input   logic   [NUMBER_MASTER-1:0]             request_wr,
    output  logic   [$clog2(NUMBER_MASTER)-1:0]     grant_wr,

    input   logic                                   s_axil_bvalid,
    input   logic   [NUMBER_MASTER-1:0]             m_axil_bready
);

    logic [$clog2(NUMBER_MASTER)-1:0] next_grant;

    typedef enum logic [1:0]
    {  
        IDLE,
        GRANT,
        ACKN
    } state_type;

    state_type state_arb;

    always_ff @(posedge aclk) 
    begin
        if (!aresetn)
        begin
            state_arb <= IDLE;
            grant_wr <= '0;
        end else
        begin
            case (state_arb)
                IDLE:
                    begin
                        if (~|request_wr)
                        begin
                            state_arb <= IDLE;
                        end else
                        begin
                            state_arb <= GRANT;
                        end
                    end
                GRANT:
                    begin
                        state_arb <= ACKN;
                        grant_wr <= next_grant;
                    end
                ACKN:
                    begin
                        if (!(s_axil_bvalid && m_axil_bready[grant_wr]))
                        begin
                            state_arb <= ACKN;
                        end else
                        begin
                            state_arb <= IDLE;
                            grant_wr <= '0;
                        end
                    end
            endcase
        end
    end

    always_comb 
    begin
        next_grant = '0;

        for (int i = 0; i < NUMBER_MASTER; i++) 
        begin
            if (request_wr[i]) 
            begin
                next_grant = i;
                break;
            end
        end
    end

endmodule