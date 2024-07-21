module axil_arbiter_priority_rd
#(
    parameter   NUMBER_MASTER   =   2
)

(
    input   logic                                   aclk,
    input   logic                                   aresetn,

    input   logic   [NUMBER_MASTER-1:0]             request_rd,
    output  logic   [$clog2(NUMBER_MASTER)-1:0]     grant_rd,

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
            grant_rd <= '0;
        end else
        begin
            case (state_arb)
                IDLE:
                    begin
                        if (~|request_rd)
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
                        grant_rd <= next_grant;
                    end
                ACKN:
                    begin
                        if (!(s_axil_bvalid && m_axil_bready[grant_rd]))
                        begin
                            state_arb <= ACKN;
                        end else
                        begin
                            state_arb <= IDLE;
                            grant_rd <= '0;
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
            if (request_rd[i]) 
            begin
                next_grant = i;
                break;
            end
        end
    end

endmodule