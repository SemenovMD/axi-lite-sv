module axil_arbiter_priority_wr

    import axil_pkg ::*;

(
    input   logic                                   aclk,
    input   logic                                   aresetn,

    input   logic   [NUMBER_MASTER-1:0]             request_wr,
    output  logic   [NUMBER_MASTER-1:0]             grant_wr,

    input   logic                                   s_axil_bvalid,
    input   logic   [NUMBER_MASTER-1:0]             m_axil_bready
);

    logic           [$clog2(NUMBER_MASTER)-1:0]     grant_wr_cdr;

    logic           [NUMBER_MASTER-1:0]             next_grant;
    logic           [$clog2(NUMBER_MASTER)-1:0]     next_grant_cdr;

    typedef enum logic
    {  
        IDLE,
        ACKN
    } state_type;

    state_type state_arb;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_arb <= IDLE;
            grant_wr <= '0;
            grant_wr_cdr <= '0;
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
                            state_arb <= ACKN;
                            grant_wr <= next_grant;
                            grant_wr_cdr <= next_grant_cdr;
                        end
                    end
                ACKN:
                    begin
                        if (!(s_axil_bvalid && m_axil_bready[grant_wr_cdr]))
                        begin
                            state_arb <= ACKN;
                        end else
                        begin
                            state_arb <= IDLE;
                            grant_wr <= '0;
                            grant_wr_cdr <= '0;
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
                next_grant[i] = 1;
                break;
            end
        end
    end

    always_comb 
    begin
        next_grant_cdr = '0;

        for (int i = 0; i < NUMBER_MASTER; i++) 
        begin
            if (next_grant[i]) 
            begin
                next_grant_cdr = i;
            end
        end
    end

endmodule