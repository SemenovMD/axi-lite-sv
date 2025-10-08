module axil_arbiter_wr

    import axil_pkg ::*;

(
    input   logic                                   aclk,
    input   logic                                   aresetn,

    input   logic   [NUMBER_MASTER-1:0]             request_wr,
    output  logic   [NUMBER_MASTER-1:0]             grant_wr,

    input   logic                                   s_axil_bvalid,
    input   logic   [NUMBER_MASTER-1:0]             m_axil_bready
);

    generate
        if (ARBITER_WR) begin
            /////////////////////////////////////////////////////////////////////////////////////////////////////////
            // ARBITER Round Robin
            /////////////////////////////////////////////////////////////////////////////////////////////////////////
            logic           [$clog2(NUMBER_MASTER)-1:0]     grant_wr_cdr;
            logic           [NUMBER_MASTER-1:0]             grant_wr_buf;

            logic           [NUMBER_MASTER-1:0]             next_grant;
            logic           [$clog2(NUMBER_MASTER)-1:0]     next_grant_cdr;

            logic           [$clog2(NUMBER_MASTER)-1:0]     last_index;

            logic           [NUMBER_MASTER-1:0]             mask;
            logic           [NUMBER_MASTER-1:0]             masked_req;
            logic           [NUMBER_MASTER-1:0]             grant_upper;
            logic           [NUMBER_MASTER-1:0]             grant_lower;

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
                    grant_wr_buf <= '0;
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
                                    grant_wr_buf <= next_grant;
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

            assign mask        = {NUMBER_MASTER{1'b1}} << (last_index + 1);

            assign masked_req  = request_wr & mask;
            assign grant_upper = masked_req & -masked_req;
            assign grant_lower = request_wr & -request_wr;
            assign next_grant  = (|masked_req) ? grant_upper : grant_lower;

            always_comb 
            begin
                last_index = '0;

                for (int i = 0; i < NUMBER_MASTER; i++) 
                begin
                    if (grant_wr_buf[i]) 
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
            /////////////////////////////////////////////////////////////////////////////////////////////////////////
        end else begin
            /////////////////////////////////////////////////////////////////////////////////////////////////////////
            // ABRIBER PRIORITY
            /////////////////////////////////////////////////////////////////////////////////////////////////////////
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
            /////////////////////////////////////////////////////////////////////////////////////////////////////////
        end
    endgenerate

endmodule