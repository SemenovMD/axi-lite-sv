module axil_arbiter_rr_rd

    import axil_pkg ::*;

(
    input   logic                                   aclk,
    input   logic                                   aresetn,

    input   logic   [NUMBER_MASTER-1:0]             request_rd,
    output  logic   [NUMBER_MASTER-1:0]             grant_rd,

    input   logic                                   s_axil_rvalid,
    input   logic   [NUMBER_MASTER-1:0]             m_axil_rready
);

    logic           [$clog2(NUMBER_MASTER)-1:0]     grant_rd_cdr;
    logic           [NUMBER_MASTER-1:0]             grant_rd_buf;

    logic           [NUMBER_MASTER-1:0]             next_grant;
    logic           [$clog2(NUMBER_MASTER)-1:0]     next_grant_cdr;

    logic           [$clog2(NUMBER_MASTER)-1:0]     index;
    logic           [$clog2(NUMBER_MASTER)-1:0]     last_index;

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
            grant_rd <= '0;
            grant_rd_buf <= '0;
            grant_rd_cdr <= '0;
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
                            state_arb <= ACKN;
                            grant_rd <= next_grant;
                            grant_rd_buf <= next_grant;
                            grant_rd_cdr <= next_grant_cdr;
                        end
                    end
                ACKN:
                    begin
                        if (!(s_axil_rvalid && m_axil_rready[grant_rd_cdr]))
                        begin
                            state_arb <= ACKN;
                        end else
                        begin
                            state_arb <= IDLE;
                            grant_rd <= '0;
                            grant_rd_cdr <= '0;
                        end
                    end
            endcase
        end
    end

    always_comb begin
        next_grant = '0;
        
        for (int i = 0; i < NUMBER_MASTER; i++) begin
            index = (last_index + i + 1 >= NUMBER_MASTER) ? (last_index + i + 1 - NUMBER_MASTER) : (last_index + i + 1);
            
            if (request_rd[index]) begin
                next_grant = (1 << index);
                break;
            end
        end
    end

    always_comb 
    begin
        last_index = '0;

        for (int i = 0; i < NUMBER_MASTER; i++) 
        begin
            if (grant_rd_buf[i]) 
            begin
                last_index = i;
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